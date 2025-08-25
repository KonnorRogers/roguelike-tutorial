module App
  module Entities
    class Entity < SpriteKit::Sprite
      def collideable?
        true
      end

      def attack(entity:)
        GTK.notify("Attacking #{entity.type}")
        true
      end

      def move(map, direction:)
        dx = 0
        dy = 0
        if direction == :up
          dy += @speed
        elsif direction == :down
          dy -= @speed
        elsif direction == :left
          dx -= @speed
          @flip_horizontally = true
        elsif direction == :right
          dx += @speed
          @flip_horizontally = false
        end

        @y += dy
        @x += dx

        collisions = map.collisions(self)
        collision = collisions[0]
        if collision || map.out_of_bounds?(self)
          @y -= dy
          @x -= dx

          if collision
            return attack(entity: collision)
          end

          return false
        end

        true
      end

      def move_up(map)
        move(map, direction: :up)
      end

      def move_down(map)
        move(map, direction: :down)
      end

      def move_right(map)
        move(map, direction: :right)
      end

      def move_left(map)
        move(map, direction: :left)
      end
    end
  end
end
