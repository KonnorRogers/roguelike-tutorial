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
          walls: {},
          entities: @dungeon.entities
        )
        @player = @dungeon.player
        @camera.target_x = @player.x * TILE_SIZE
        @camera.target_y = @player.y * TILE_SIZE

        @health_bar = App::Ui::HealthBar.new(entity: @player, x: 72, y: 72.from_top, w: 300, h: 36)
        @update_fov = nil
        @show_all_tiles = false
      end

      def update_scaled_tiles
        @scaled_tiles = Array.map(@dungeon.flat_tiles) { |tile| scale_for_screen(tile.serialize) }
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
          @camera_scale_changed = true
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
          @camera_scale_changed = true
          @update_fov = true
        elsif @inputs.keyboard.key_down.minus
          @camera.target_scale -= 0.25
          @camera.target_scale = 0.25 if @camera.target_scale < 0.25
          @camera_scale_changed = true
          @update_fov = true
        elsif @inputs.keyboard.zero
          @camera.target_scale = 1
          @camera_scale_changed = true
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

        if @camera_scale_changed
          update_scaled_tiles
        end

        if @update_fov
          @dungeon.update_field_of_view
          update_visible_tiles
        end
      end

      def update_visible_tiles
        @visible_tiles = Array.map(@dungeon.visible_tiles) do |tile|
          scale_for_screen(tile.serialize)
        end

        # Tiles explored, but out of view.
        @out_of_view_explored_tiles = []

        Array.each(@dungeon.explored_tiles) do |tile|
          next if @dungeon.visible_tiles.include?(tile)

          serialized_tile = tile.serialize.merge!({ a: 128 })
          @out_of_view_explored_tiles << scale_for_screen(serialized_tile)
        end

        @visible_and_out_of_view_tiles = @visible_tiles.concat(@out_of_view_explored_tiles)
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
        @outputs.debug << "TILES: #{@dungeon.flat_tiles.length}"

        @draw_buffer.primitives << { **@camera.viewport, path: @camera_path }

        @floating_text.add("Player.", entity: @player.serialize)

        @draw_buffer.primitives.concat(@health_bar.prefab)

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

        @draw_buffer[:top_layer].concat([
          {
            x: 500.from_right - 16,
            w: 750,
            y: 120.from_top,
            h: 120,
            r: 0,
            b: 0,
            g: 0,
            a: 255,
            # blendmode_enum: 0,
            path: :solid
          },
          {
            x: 500.from_right,
            y: 50.from_top,
            text: "Hit '.' to show the full map",
            primitive_marker: :label,
            scale_quality: 2,
            anchor_x: 0,
            anchor_y: 0,
            size_px: 26,
            # blendmode_enum: 0,
            r: 255,
            b: 255,
            g: 255,
            a: 255
          },
          {
            x: 500.from_right,
            y: 100.from_top,
            text: "Use '-' and '=' keys to zoom in / out",
            primitive_marker: :label,
            scale_quality: 2,
            anchor_x: 0,
            anchor_y: 0,
            size_px: 26,
            # blendmode_enum: 0,
            r: 255,
            b: 255,
            g: 255,
            a: 255
          }
        ])

      end

      def draw
        super
        @outputs[:top_layer].primitives.concat(@gtk.framerate_diagnostics_primitives.map do |primitive|
          primitive.y = (@args.grid.h * -1) + 90 + primitive.y
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
        @draw_buffer[@camera_path].concat(Geometry.find_all_intersect_rect(@camera.viewport, @visible_and_out_of_view_tiles))

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
