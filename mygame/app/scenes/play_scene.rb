require "vendor/sprite_kit/sprite_kit.rb"
require "app/procgen"
require "app/ui/health_bar"
require "app/floating_text"

module App
  module Scenes
    class PlayScene < SpriteKit::Scene
      MOVE_X = 16
      MOVE_Y = 16

      attr_accessor :dungeon, :camera, :graph, :player, :healthbar, :floating_text, :game_log

      def initialize(...)
        super(...)
        reset
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

        @dungeon = App::Procgen.generate_dungeon(
          engine: self,
          max_rooms: max_rooms,
          room_min_size: room_min_size,
          room_max_size: room_max_size,
          map_height: map_height,
          map_width: map_width,
          max_monsters_per_room: max_monsters_per_room,
        )

        @floating_text = FloatingText.new(draw_buffer: @draw_buffer, target: @camera_path)

        @graph = App::Pathfinding::Graph.new(
          cells: @dungeon.tiles,
          walls: @dungeon.walls,
          entities: @dungeon.entities
        )
        @player = @dungeon.player
        @camera.target_x = @player.x * TILE_SIZE
        @camera.target_y = @player.y * TILE_SIZE

        @health_bar = App::Ui::HealthBar.new(entity: @player, x: 72, y: 72.from_top, w: 300, h: 36)
        @update_fov = nil
        @show_all_tiles = false
      end

      def input
        keyboard = @inputs.keyboard

        if @player.dead?
          @did_move = false
          return
        end

        @did_move = if keyboard.key_down.left_arrow
                      @player.move_left(@dungeon)
                    elsif keyboard.key_down.right_arrow
                      @player.move_right(@dungeon)
                    elsif keyboard.key_down.up_arrow
                      @player.move_up(@dungeon)
                    elsif keyboard.key_down.down_arrow
                      @player.move_down(@dungeon)
                    else
                      false
                    end

        # used for rendering FOV
        @update_fov = @update_fov.nil? || @did_move # for first render, check if there's any visible tiles.

        if keyboard.key_down.period
          @show_all_tiles = !@show_all_tiles
          @update_fov = true
        end

        @camera.target_x = @player.x * TILE_SIZE
        @camera.target_y = @player.y * TILE_SIZE

        handle_camera_zoom

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
          @update_fov = true
        elsif @inputs.keyboard.key_down.minus
          @camera.target_scale -= 0.25
          @camera.target_scale = 0.25 if @camera.target_scale < 0.25
          @update_fov = true
        elsif @inputs.keyboard.zero
          @camera.target_scale = 1
          @update_fov = true
        end
      end

      def calc_camera
        ease = 1
        @camera.scale += (@camera.target_scale - @camera.scale) * ease
        @camera.x += (@camera.target_x - @camera.x) * ease
        @camera.y += (@camera.target_y - @camera.y) * ease
      end

      def calc
        calc_camera

        if @did_move
          @dungeon.entities.each do |entity|
            next if entity == @player

            entity.take_turn
          end
        end

        if @update_fov
          @dungeon.update_field_of_view
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
        @draw_buffer.primitives << { **@camera.viewport, path: @camera_path }

        @floating_text.add("Player.", entity: @player.serialize)

        # entity.x -= @camera.offset_x
        # entity.y += @camera.offset_y

        # entity = scale_for_screen(@player.serialize)
        # entity.x += (@camera.w / 2)
        # @outputs.debug << "#{entity}"
        # @outputs.debug << "#{@camera.serialize}"

        @draw_buffer.primitives.concat(@health_bar.prefab)
        # @outputs.debug << "Enemies: #{(@dungeon.entities.length - 1)}"
        # @outputs.debug << "Tiles: #{@dungeon.flat_tiles.length}"
        # @outputs.debug << "Size: #{@dungeon.w} x #{@dungeon.h}"
        @draw_buffer[:top_layer].concat(@gtk.framerate_diagnostics_primitives.map do |primitive|
          primitive.y = (@args.grid.h * -1) + 90 + primitive.y
          primitive.scale_quality = 2
          primitive
        end)

        if @player.dead?
          render_game_over_screen
        end

        # if !@update_fov
          # @floating_text.flush
          # return
        # end

        camera_render_target

        if @show_all_tiles
          render_all_tiles
        else
          render_visible_tiles
        end

        @floating_text.flush
      end

      def render_all_tiles
        # @outputs.debug << "FLAT_WALLS: " + @dungeon.flat_walls.map { |tile| tile.serialize }.to_s
        @outputs.debug << "#{@dungeon.player.x}, #{@dungeon.player.y}"
        tiles = []
        max_x = @dungeon.player.x + 20
        min_x = (@dungeon.player.x - 20).clamp(0, @dungeon.player.x)

        max_y = @dungeon.player.y + 20
        min_y = (@dungeon.player.y - 20).clamp(0, @dungeon.player.y)

        x_range = (min_x..max_x)
        y_range = (min_y..max_y)

        x_range.each do |x|
          x_tile = @dungeon.tiles[x]
          x_wall = @dungeon.walls[x]

          if !x_tile
            x_tile = nil
            x_wall = nil
            next
          end

          y_range.each do |y|
            tile = x_tile[y]
            wall = x_wall[y]

            if tile
              tiles << scale_for_screen(tile.serialize)
            end

            if wall
              tiles << scale_for_screen(wall.serialize)
            end
          end
        end

        # tiles = Array(@dungeon.flat_tiles).map do |tile|
        #   scale_for_screen(tile.serialize)
        # end

        entities = Array(@dungeon.entities)
          .map { |entity| scale_for_screen(entity.serialize) }

        # @draw_buffer[@camera_path].concat(Geometry.find_all_intersect_rect(@camera.viewport, tiles))
        @draw_buffer[@camera_path].concat(tiles)
        @draw_buffer[@camera_path].concat(Geometry.find_all_intersect_rect(@camera.viewport, entities).sort_by(&:draw_order))
      end

      def render_visible_tiles
        tiles = Array(@dungeon.visible_tiles).map do |tile|
          scale_for_screen(tile.serialize)
        end

        # # Tiles explored, but out of view.
        out_of_view_explored_tiles = Array(@dungeon.explored_tiles).reject { |tile| @dungeon.visible_tiles.include?(tile) }

        tiles.concat(Array(out_of_view_explored_tiles).map do |tile|
          serialized_tile = tile.serialize.merge!({ a: 128 })
          scale_for_screen(serialized_tile)
        end)

        @draw_buffer[@camera_path].concat(Geometry.find_all_intersect_rect(@camera.viewport, tiles))

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
