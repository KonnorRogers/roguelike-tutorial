module App
  module Entities
    module Mixins
      module Fighter
        def self.included(base)
          base.prepend(PrependedMethods)
        end

        module PrependedMethods
          def initialize(**kwargs)
            super(**kwargs)

            required_variables = [
              "@health",
              "@max_health",
              "@defense",
              "@power",
              "@speed",
            ]

            unset_properties = []
            required_variables.each do |var|
              if instance_variable_get(var).nil?
                unset_properties << var
              end
            end

            if unset_properties.length > 0
              raise StandardError.new("#{unset_properties.join(", ")} ivars not set for #{self}")
            end
          end
        end

        attr_accessor :health,
                      :max_health,
                      :defense,
                      :power,
                      :speed

        def health
          @health
        end

        def take_damage(damage)
          @health -= damage
        end

        def health=(val)
          @health = val.clamp(0, @max_health)
        end

        def attack(entity:)
          raise NotImplementedError.new("#attack(entity:) not implemented by #{self.class}")
        end

        def dead?
          @health <= 0
        end

        def alive?
          @health > 0
        end

        def move(dungeon, direction:)
          current_tile = @dungeon.tiles[@x][@y]
          if dead?
            return false
          end

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

          collisions = dungeon.collisions(self)
          collision = collisions[0]
          if collision || dungeon.out_of_bounds?(self)
            @y -= dy
            @x -= dx

            if collision
              return attack(entity: collision)
            end

            return false
          end

          true
        end

        def move_up(dungeon)
          move(dungeon, direction: :up)
        end

        def move_down(dungeon)
          move(dungeon, direction: :down)
        end

        def move_right(dungeon)
          move(dungeon, direction: :right)
        end

        def move_left(dungeon)
          move(dungeon, direction: :left)
        end
      end
    end
  end
end
