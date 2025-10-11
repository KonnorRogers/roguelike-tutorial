require "vendor/sprite_kit/sprite_kit.rb"
require "app/procgen"
require "app/ui/health_bar"
require "app/ui/inventory"
require "app/floating_text"
require "app/game_log"
require "app/ui/item_menu"

module App
  module Scenes
    class PlayScene < SpriteKit::Scene
      MOVE_X = 16
      MOVE_Y = 16

      attr_accessor :dungeon, :camera, :graph, :player, :healthbar, :floating_text, :game_log

      def initialize(...)
        super(...)
        reset
        @benchmarks = {}
      end

      def bench(sym)
        start_time = Time.now

        yield if block_given?

        end_time = Time.now - start_time

        # Max:
        @benchmarks[sym] ||= end_time
        @benchmarks[sym] = end_time if end_time > @benchmarks[sym]

        # Current:
        # @benchmarks[sym] = end_time
      end

      def reset
        @camera = SpriteKit::Camera.new
        @camera_path = :camera

        map_width = 80
        map_height = 45
        room_max_size = 10
        room_min_size = 6
        max_rooms = 30
        max_monsters_per_room = 2
        max_items_per_room = 2

        @dungeon = App::Procgen.generate_dungeon(
          engine: self,
          max_rooms: max_rooms,
          room_min_size: room_min_size,
          room_max_size: room_max_size,
          map_height: map_height,
          map_width: map_width,
          max_monsters_per_room: max_monsters_per_room,
          max_items_per_room: max_items_per_room
        )

        @floating_text = FloatingText.new(draw_buffer: @draw_buffer, target: @camera_path)

        @graph = @dungeon.graph
        @player = @dungeon.player
        @camera.target_x = @player.x * TILE_SIZE
        @camera.target_y = @player.y * TILE_SIZE

        @health_bar = App::Ui::HealthBar.new(entity: @player, x: 50, y: 50)
        @inventory = App::Ui::Inventory.new(items: @player.inventory)
        @item_menu = Ui::ItemMenu.new
        @update_fov = nil
        @show_all_tiles = false
        @scaled_tiles = []
        @visible_and_out_of_view_tiles = []

        @game_log = GameLog.new
        update_scaled_tiles
        @show_inventory = false
      end

      def update_scaled_tiles
        idx = 0
        loop do
          break if idx > @dungeon.flat_tiles.length - 1

          tile = @dungeon.flat_tiles[idx]
          tile = tile.dup.tap do |t|
            t.x = t.x * TILE_SIZE
            t.y = t.y * TILE_SIZE
            t.w = t.w * TILE_SIZE
            t.h = t.h * TILE_SIZE
          end
          @scaled_tiles[idx] = @camera.to_screen_space!(tile)
          idx += 1
        end
      end

      def input
        @camera_updated = false

        bench(:input) do
          keyboard = @inputs.keyboard

          if @inputs.mouse.click
            if @show_inventory
              clicked_button = nil

              if @item_menu.open
                clicked_button = Geometry.find_all_intersect_rect(@inputs.mouse, @item_menu.rendered_buttons.values)[0]
                if clicked_button == @item_menu.rendered_buttons[:drop]
                  @player.drop(@item_menu.item)
                end
                if clicked_button == @item_menu.rendered_buttons[:use]
                  @player.use(@item_menu.item)
                end

                if clicked_button == @item_menu.rendered_buttons[:throw]
                  @player.throw(@item_menu.item)
                end
              end

              clicked_item = Geometry.find_all_intersect_rect(@inputs.mouse, @inventory.rendered_items)[0]
              if !clicked_button
                if clicked_item
                  @item_menu.item = clicked_item
                  @item_menu.open = true
                else
                  @item_menu.open = false
                end
              end
            end

            if @inputs.mouse.intersect_rect?(@inventory.backpack_icon_bounding_box)
              @show_inventory = !@show_inventory
            end
          end

          if keyboard.key_down.b
            @show_inventory = !@show_inventory
          end

          if @player.dead?
            @did_move = false
            return
          end

          key_down = keyboard.key_down

          @did_move = if key_down.left_arrow || key_down.a
                        @player.move_left(@dungeon)
                      elsif key_down.right_arrow || key_down.d
                        @player.move_right(@dungeon)
                      elsif key_down.up_arrow || key_down.w
                        @player.move_up(@dungeon)
                      elsif key_down.down_arrow || key_down.s
                        @player.move_down(@dungeon)
                      elsif keyboard.key_down.space
                        # Wait...
                        true
                      else
                        false
                      end

          # used for rendering FOV
          @update_fov = @update_fov.nil? || @did_move # for first render, check if there's any visible tiles.
          @camera_updated = @did_move && @show_all_tiles

          if keyboard.key_down.period
            @show_all_tiles = !@show_all_tiles
            @update_fov = true
            @camera_updated = true
          end

          if keyboard.key_down.e
            items_on_player = @dungeon.entities.select { |item| item.item? && item.x == @player.x && item.y == @player.y }
            items_on_player.each { |item| @player.pickup(item) }
          end

          @camera.target_x = @player.x * TILE_SIZE
          @camera.target_y = @player.y * TILE_SIZE

          handle_camera_zoom
        end
      end

      def camera_render_target
        rt = @outputs[@camera_path]
        viewport = @camera.viewport
        rt.w = viewport.w
        rt.h = viewport.h
        rt.background_color = [0,0,0,255]
        # rt.clear_before_render = false
        rt
      end

      def handle_camera_zoom
        # Zoom
        if @inputs.keyboard.key_down.equal_sign || @inputs.keyboard.key_down.plus
          @camera.target_scale += 0.25
          @camera_updated = true
          @update_fov = true
        elsif @inputs.keyboard.key_down.minus
          @camera.target_scale -= 0.25
          @camera.target_scale = 0.5 if @camera.target_scale < 0.5
          @camera_updated = true
          @update_fov = true
        elsif @inputs.keyboard.zero
          @camera.target_scale = 1
          @camera_updated = true
          @update_fov = true
        end
      end

      def calc_camera
        @camera.scale += (@camera.target_scale - @camera.scale)
        @camera.x += (@camera.target_x - @camera.x)
        @camera.y += (@camera.target_y - @camera.y)
      end

      def calc
        bench(:calc) do
          calc_camera

          if @did_move
            @dungeon.entities.each do |entity|
              next if entity == @player
              next if entity.item?

              entity.take_turn
            end
          end

          if @update_fov
            @dungeon.update_field_of_view
            update_visible_tiles

            if @show_all_tiles
              update_scaled_tiles
            end
          end
        end
      end

      def update_visible_tiles
        @visible_and_out_of_view_tiles = []

        idx = 0
        loop do
          break if idx > @dungeon.flat_tiles.length - 1

          original_tile = @dungeon.flat_tiles[idx]

          break if !original_tile

          if !@dungeon.explored_tiles.has_key?(original_tile)
            idx += 1
            next
          end

          tile = original_tile.dup.tap do |t|
            t.x = t.x * TILE_SIZE
            t.y = t.y * TILE_SIZE
            t.w = t.w * TILE_SIZE
            t.h = t.h * TILE_SIZE
            t.a = 128 if !@dungeon.visible_tiles.include?(original_tile)
          end
          @camera.to_screen_space!(tile)
          @visible_and_out_of_view_tiles << tile
          idx += 1
        end
      end

      def scale_for_screen(sprite)
        @camera.to_screen_space(sprite.merge({
          x: sprite.x * TILE_SIZE,
          y: sprite.y * TILE_SIZE,
          w: sprite.w * TILE_SIZE,
          h: sprite.h * TILE_SIZE
        }))
      end

      def render
        @game_log.update
        @game_log.render(@draw_buffer)

        bench(:render) do
          @outputs.debug << "TILES: #{@dungeon.flat_tiles.length}"
          # @outputs.debug << "OBJECTS:"
          # ObjectSpace.count_objects.each do |k, v|
          #   @outputs.debug << "#{k}: #{v}"
          # end

          @draw_buffer.primitives << { **@camera.viewport, path: @camera_path }

          bottom_menu = Layout.rect(row: Layout.row_count - 1, col: 1, h: 1, w: Layout.col_count / 4)
          @health_bar.h = bottom_menu.h
          @health_bar.w = bottom_menu.w
          @health_bar.x = bottom_menu.x
          @health_bar.y = bottom_menu.y
          @draw_buffer.primitives.concat(@health_bar.prefab)
          @draw_buffer.primitives.concat(@inventory.render_backpack_icon)

          if @show_inventory
            @draw_buffer.primitives.concat(@inventory.render_inventory)
          else
            @item_menu.open = false
          end

          if @item_menu.open
            @draw_buffer.primitives.concat(@item_menu.render)
          end

          if @player.dead?
            render_game_over_screen
          end

          camera_render_target

          if @show_all_tiles
            render_all_tiles
          else
            render_visible_tiles
          end

          @floating_text.flush

          # @draw_buffer[:top_layer].concat([
          #   {
          #     x: 500.from_right - 16,
          #     w: 750,
          #     y: 120.from_top,
          #     h: 120,
          #     r: 0,
          #     b: 0,
          #     g: 0,
          #     a: 255,
          #     # blendmode_enum: 0,
          #     path: :solid
          #   },
          #   {
          #     x: 500.from_right,
          #     y: 50.from_top,
          #     text: "Hit '.' to show the full map",
          #     primitive_marker: :label,
          #     scale_quality: 2,
          #     anchor_x: 0,
          #     anchor_y: 0,
          #     size_px: 26,
          #     # blendmode_enum: 0,
          #     r: 255,
          #     b: 255,
          #     g: 255,
          #     a: 255
          #   },
          #   {
          #     x: 500.from_right,
          #     y: 100.from_top,
          #     text: "Use '-' and '=' keys to zoom in / out",
          #     primitive_marker: :label,
          #     scale_quality: 2,
          #     anchor_x: 0,
          #     anchor_y: 0,
          #     size_px: 26,
          #     # blendmode_enum: 0,
          #     r: 255,
          #     b: 255,
          #     g: 255,
          #     a: 255
          #   }
          # ])
        end

        @draw_buffer.primitives << @game_log

        if Kernel.tick_count == 0
          # @outputs.static_primitives << Layout.debug_primitives
        end
      end

      def draw
        bench(:draw) do
          super
        end
        @outputs.debug << "Benchmarks: "
        @benchmarks.each do |k, v|
          @outputs.debug << "#{k}: #{(v * 1000).to_s}ms"
        end
        @outputs[:top_layer].primitives.concat(@gtk.framerate_diagnostics_primitives.map do |primitive|
          primitive.x = 500.from_right + primitive.x
          primitive.scale_quality = 2
          primitive
        end)
      end

      def render_all_tiles
        entities = Array.map(@dungeon.entities) { |entity| scale_for_screen(entity.serialize) }

        @draw_buffer[@camera_path].concat(Geometry.find_all_intersect_rect(@camera.viewport, @scaled_tiles))
        @draw_buffer[@camera_path].concat(Geometry.find_all_intersect_rect(@camera.viewport, entities).sort_by(&:draw_order))
      end

      def render_visible_tiles
        @draw_buffer[@camera_path].concat(@visible_and_out_of_view_tiles)

        visible_entities = @dungeon.visible_entities
          .sort_by(&:draw_order)
          .map { |entity| scale_for_screen(entity.serialize) }

        @draw_buffer[@camera_path].concat(visible_entities)
      end

      def render_game_over_screen
        w = 600
        h = 400
        x = (Grid.w / 2) - (w / 2)
        y = (Grid.h / 2).from_top - (h / 2)
        border_width = 2

        game_over_background = {
          x: x + border_width,
          y: y + border_width,
          w: w - (border_width * 2),
          h: h - (border_width * 2),
          r: 0,
          b: 0,
          g: 0,
          a: 200,
          primitive_marker: :sprite,
          path: :pixel
        }
        game_over_borders = ::SpriteKit::Primitives.borders({
          x: x,
          y: y,
          h: h,
          w: w,
        }, padding: 0, color: { r: 255, b: 255, g: 255, a: 255 }).values
        game_over_label = {
          x: x + (w / 2),
          y: y + (h / 2),
          text: "Game Over.",
          anchor_x: 0.5,
          anchor_y: 0,
          size_px: 80,
          r: 255,
          b: 255,
          g: 255,
          a: 255,
          primitive_marker: :label
        }
        try_again_label = game_over_label.merge({
          y: game_over_label.y - 120,
          size_px: 44,
          text: "Click to play again!"
        })
        @draw_buffer.primitives.concat(game_over_borders).concat([
          game_over_background,
          game_over_label,
          try_again_label
        ])



        if @inputs.mouse.click
          reset
        end
      end
    end
  end
end
