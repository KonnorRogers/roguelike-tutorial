require "vendor/sprite_kit/sprite_kit.rb"
require "app/procgen"

module App
  module Scenes
    class PlayScene < SpriteKit::Scene
      MOVE_X = 16
      MOVE_Y = 16

      attr_accessor :dungeon

      def initialize(...)
        super(...)

        @camera = SpriteKit::Camera.new
        @camera_path = :camera

        map_width = 80
        map_height = 45
        room_max_size = 10
        room_min_size = 6
        max_rooms = 30
        max_monsters_per_room = 2

        @player = App::Entities::Player.new
        @dungeon = App::Procgen.generate_dungeon(
          max_rooms: max_rooms,
          room_min_size: room_min_size,
          room_max_size: room_max_size,
          map_height: map_height,
          map_width: map_width,
          max_monsters_per_room: max_monsters_per_room,
          player: @player,
        )

        @camera.target_x = @player.x * TILE_SIZE
        @camera.target_y = @player.y * TILE_SIZE

        @visible_tiles = []
        @show_all_tiles = false
      end

      def input
        keyboard = @inputs.keyboard

        if keyboard.key_down.period
          @show_all_tiles = !@show_all_tiles
        end

        @did_move = if keyboard.key_down.left_arrow
                      @player.move_left(@dungeon)
                    elsif keyboard.key_down.right_arrow
                      @player.move_right(@dungeon)
                    elsif keyboard.key_down.up_arrow
                      @player.move_up(@dungeon)
                    elsif keyboard.key_down.down_arrow
                      @player.move_down(@dungeon)
                    end

        # used for rendering FOV
        @requires_update = @did_move || @visible_tiles.length == 0 # for first render, check if there's any visible tiles.

        if @did_move
          @dungeon.entities.each do |entity|
            next if entity == @player

            entity.take_turn
          end
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
        rt
      end

      def handle_camera_zoom
        # Zoom
        if @inputs.keyboard.key_down.equal_sign || @inputs.keyboard.key_down.plus
          @camera.target_scale += 0.25
        elsif @inputs.keyboard.key_down.minus
          @camera.target_scale -= 0.25
          @camera.target_scale = 0.25 if @camera.target_scale < 0.25
        elsif @inputs.keyboard.zero
          @camera.target_scale = 1
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

        if @requires_update
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
        camera_render_target
        @draw_buffer.primitives << { **@camera.viewport, path: @camera_path }

        if !@requires_update
          return
        end

        if @show_all_tiles
          @draw_buffer[@camera_path].concat(@dungeon.flat_tiles.map do |tile|
            scale_for_screen(tile.serialize)
          end)

          @draw_buffer[@camera_path].concat(@dungeon.entities.map { |entity| scale_for_screen(entity.serialize) })
        else
          @draw_buffer[@camera_path].concat(@dungeon.visible_tiles.map do |tile|
            scale_for_screen(tile.serialize)
          end)

          # # Tiles explored, but out of view.
          out_of_view_explored_tiles = @dungeon.explored_tiles.reject { |tile| @visible_tiles.include?(tile) }
          @draw_buffer[@camera_path].concat(out_of_view_explored_tiles.map do |tile|
            serialized_tile = tile.serialize.merge({ a: 128 })
            scale_for_screen(serialized_tile)
          end.flatten)

          @draw_buffer[@camera_path].concat(@dungeon.visible_entities.map { |entity| scale_for_screen(entity.serialize) })
        end

        @top_layer.scale_quality = 2
        @draw_buffer[:top_layer].concat(@gtk.framerate_diagnostics_primitives.map do |primitive|
          primitive.x = @args.grid.w - 500 + primitive.x
          primitive.scale_quality = 2
          primitive
        end)
      end
    end
  end
end
