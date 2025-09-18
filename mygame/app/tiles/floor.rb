module App
  module Tiles
    class Floor < SpriteKit::Sprite
      FLOOR_ENUM = {
        floor__blank: :floor__blank
      }.freeze

      FLOOR_LEGEND = {
        floor__blank: proc { Floor.new(type: :blank) }
      }.freeze

      FLOOR_SPRITES = {
        blank: {
          source_x: 0,
          source_y: 357,
          source_h: 16,
          source_w: 16,
          path: App::SPRITESHEET_PATH
        }
      }

      attr_accessor :movement_cost

      def initialize(type:, **kwargs)
        super(**kwargs)
        @type = type

        @movement_cost = 1

        set_sprite
      end

      def collideable?
        false
      end

      def blocks_sight?
        false
      end

      def set_sprite
        sprite = FLOOR_SPRITES[@type]

        @source_x = sprite.source_x
        @source_y = sprite.source_y
        @source_w = sprite.source_w
        @source_h = sprite.source_h
        @path = sprite.path
      end
    end
  end
end
