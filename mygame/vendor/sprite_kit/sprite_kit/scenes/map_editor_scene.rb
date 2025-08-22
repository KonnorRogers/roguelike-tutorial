require SpriteKit.to_load_path("map_editor")

module SpriteKit
  module Scenes
    class MapEditorScene
      def initialize
        @map_editor = ::SpriteKit::MapEditor.new
        @camera = ::SpriteKit::Camera.new
      end

      def tick(args)
        calc_camera(args)
        move_camera(args)

        args.outputs.sprites << { **@camera.viewport, path: :scene }

        args.outputs[:scene].w = @camera.w
        args.outputs[:scene].h = @camera.h

        @map_editor.tick(args)

        # Starting map editor box.
        # start_scale = args.state.start_camera.scale
        # args.outputs[:scene].borders << Camera.to_screen_space(args.state.camera, {
        #   x: (Camera::SCREEN_WIDTH / -2) / start_scale,
        #   y: (Camera::SCREEN_HEIGHT / -2) / start_scale,
        #   w: Camera::SCREEN_WIDTH / start_scale,
        #   h: Camera::SCREEN_HEIGHT / start_scale,
        #   r: 255,
        #   g: 0,
        #   b: 0,
        #   a: 255,
        #   primitive: :border
        # })
      end

      def move_camera(args)
        inputs = args.inputs

        if args.state.text_fields.any? { |input| input.focussed? }
          return
        end

        speed = 3 + (3 / args.state.camera.scale)

        # Movement
        if inputs.keyboard.left_arrow
          args.state.camera.target_x -= speed
        elsif inputs.keyboard.right_arrow
          args.state.camera.target_x += speed
        end

        if inputs.keyboard.down_arrow
          args.state.camera.target_y -= speed
        elsif inputs.keyboard.up_arrow
          args.state.camera.target_y += speed
        end

        # Zoom
        state = args.state
        if args.inputs.keyboard.key_down.equal_sign || args.inputs.keyboard.key_down.plus
          state.camera.target_scale += 0.25
        elsif args.inputs.keyboard.key_down.minus
          state.camera.target_scale -= 0.25
          state.camera.target_scale = 0.25 if state.camera.target_scale < 0.25
        elsif args.inputs.keyboard.zero
          state.camera.target_scale = 1
        end
      end

      def calc_camera(args)
        state = args.state

        if !state.camera
          state.camera = {
            x: 0,
            y: 0,
            target_x: 0,
            target_y: 0,
            target_scale: 2,
            scale: 2
          }

          args.state.start_camera = { scale: state.camera.scale }
        end

        ease = 0.1
        state.camera.scale += (state.camera.target_scale - state.camera.scale) * ease

        state.camera.x += (state.camera.target_x - state.camera.x) * ease
        state.camera.y += (state.camera.target_y - state.camera.y) * ease
      end
    end
  end
end
