module App
  module Tiles
    class Wall < SpriteKit::Sprite
      WALL_SPRITES = {
        brick: {
          bottom_left: {
            source_x: 306,
            source_y: 323,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          middle_left: {
            source_x: 306,
            source_y: 340,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          top_left: {
            source_x: 306,
            source_y: 357,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          bottom_middle: {
            source_x: 323,
            source_y: 323,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          middle_middle: {
            source_x: 323,
            source_y: 340,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          top_middle: {
            source_x: 323,
            source_y: 357,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          bottom_right: {
            source_x: 340,
            source_y: 323,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          middle_right: {
            source_x: 340,
            source_y: 340,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          top_right: {
            source_x: 340,
            source_y: 357,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          }
        }
      }

      attr_sprite
      # attr_accessor :type, :direction

      def initialize(direction:, type:, **kwargs)
        super(**kwargs)

        @direction = direction
        @type = type
        update_self
      end

      def update_self
        sprite = WALL_SPRITES[@type][@direction]
        @source_x = sprite.source_x
        @source_y = sprite.source_y
        @source_h = sprite.source_h
        @source_w = sprite.source_w
        @path = sprite.path
      end
    end
  end
end
