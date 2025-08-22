module App
  module Entities
    class Player < SpriteKit::Sprite
      def initialize(...)
        super(...)
        @primitive_marker = :sprite
        @w ||= 16
        @h ||= 16

        @speed = 16

        @type = :player
        set_sprite
      end

      def set_sprite
        @source_x = 306
        @source_y = 204
        @source_h = 16
        @source_w = 16
        @path = App::SPRITESHEET_PATH
      end

      def move_up(map)
        @y += @speed

        if map.collision?(self)
          @y -= @speed
          return false
        end

        true
      end

      def move_down(map)
        @y -= @speed

        if map.collision?(self)
          @y += @speed
          return false
        end

        true
      end

      def move_right(map)
        @x += @speed

        @flip_horizontally = false

        if map.collision?(self)
          @x -= @speed
          return false
        end

        true
      end

      def move_left(map)
        @x -= @speed

        @flip_horizontally = true

        if map.collision?(self)
          @x += @speed
          return false
        end

        true
      end
    end
  end
end
