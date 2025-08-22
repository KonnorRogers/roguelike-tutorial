require "vendor/sprite_kit/sprite_kit.rb"
require "app/entities/player"
require "app/map"

module App
  module Scenes
    class PlayScene < SpriteKit::Scene
      MOVE_X = 16
      MOVE_Y = 16

      attr_accessor :map

      def initialize(...)
        super(...)

        @camera = SpriteKit::Camera.new
        @camera_path = :camera

        # gets multiplied by tile_size (16)
        @map = App::Map.new(w: 16, h: 16)

        @player = App::Entities::Player.new.tap do |player|
          tile_size = 16
          player.x = ((@map.w * tile_size / 2) - (player.w / 2)).ifloor(tile_size)
          player.y = ((@map.h * tile_size / 2) - (player.h / 2)).ifloor(tile_size)
        end

        @camera.target_x = @player.x
        @camera.target_y = @player.y

        @entities = [
          @player
        ]
      end

      def input
        keyboard = @inputs.keyboard
        if keyboard.key_down.left_arrow
          @player.move_left(@map)
        elsif keyboard.key_down.right_arrow
          @player.move_right(@map)
        elsif keyboard.key_down.up_arrow
          @player.move_up(@map)
        elsif keyboard.key_down.down_arrow
          @player.move_down(@map)
        end

        @camera.target_x = @player.x
        @camera.target_y = @player.y

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
      end

      def render
        camera_render_target
        @draw_buffer.primitives << { **@camera.viewport, path: @camera_path }
        @draw_buffer[@camera_path].concat(@map.flat_tiles.map do |tile|
          @camera.to_screen_space(tile.serialize)
        end)

        # @player.blendmode_enum = 0
        @draw_buffer[@camera_path] << @camera.to_screen_space(@player.serialize)

        @draw_buffer[:top_layer].concat(@gtk.framerate_diagnostics_primitives.map do |primitive|
          primitive.x = @args.grid.w - 500 + primitive.x
          primitive
        end)
      end
    end
  end
end
