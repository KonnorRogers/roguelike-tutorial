module App
  module Scenes
    class SpritesheetScene < SpriteKit::Scenes::SpritesheetScene
      def initialize(...)
        super(...)

        @state.tile_selection.w = 16
        @state.tile_selection.h = 16
        @state.tile_selection.offset_x = 0
        @state.tile_selection.offset_y = 0

        @canvas.max_width = 1000
        @canvas.spritesheets.select! do |spritesheet|
          GTK.reset_sprite(spritesheet.path)
          next true if spritesheet.path == "sprites/kenney_1-bit-pack/tilesheet/colored.png"
          next true if spritesheet.path == "sprites/kenney_1-bit-pack/tilesheet/colored-transparent.png"
          next true if spritesheet.path == "sprites/1bit-extensions.png"

          false
        end
      end

      def tick(args)
        super(args)

        camera = @state.camera
        args.outputs.debug << camera.to_s
        args.outputs.debug << camera.viewport.to_s
        args.outputs.debug << {x: camera.x, y: camera.y}.to_s
      end
    end
  end
end
