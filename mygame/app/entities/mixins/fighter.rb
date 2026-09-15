module App
  module Entities
    module Mixins
      module Fighter
        STATUSES = %i[confused paralyzed poisoned stunned].freeze

        STATUS_SPRITES = {
          confused: {
            source_x: 646,
            source_y: 136,
            source_h: 16,
            source_w: 16,
            path: "sprites/kenney_1-bit-pack/tilesheet/colored-transparent.png"
          },
          # paralyzed: {
          # },
          # poisoned: {
          # },
          # stunned: {}
        }

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
              "@inventory",
            ]

            unset_properties = []
            required_variables.each do |var|
              if instance_variable_get(var).nil?
                unset_properties << var
              end
            end

            @statuses = STATUSES.each_with_object({}) { |s, h| h[s] = false }
            if unset_properties.length > 0
              raise StandardError.new("#{unset_properties.join(", ")} ivars not set for #{self}")
            end
          end
          STATUSES.each do |status|
            define_method "#{status}?" do
              active_statuses.include?(status)
            end
            define_method("#{status}=") do |value|
              instance_variable_get("@statuses")[status] = !!value
            end
          end
        end

        attr_accessor :health,
                      :max_health,
                      :defense,
                      :power,
                      :speed,
                      :inventory,
                      :max_inventory_size,
                      :statuses

        def clear_statuses!
          @statuses.transform_values! { false }
        end

        def active_statuses
          @statuses.filter_map { |k, v| k if v }
        end

        def prefab
          [
            self,
          ]
            .concat(status_icons)
        end

        def icon(sprite)
          return nil if !sprite

          w = 0.5
          h = 0.5

          offset_x = (@w - w) / 2
          {
            x: @x + offset_x,
            y: @y + @h,
            w: w,
            h: h,
            draw_order: 3,
            a: 128,
            # a: 255,
            blendmode_enum: 2,
            **sprite
          }
        end

        def status_icons
          icons = []

          return icons if dead?

          active_statuses.each do |status|
            icons << icon(STATUS_SPRITES[status])
          end

          icons
        end

        def pickup(item)
          return false if dead?

          # Find the index of the first nil element
          first_nil_index = @inventory.find_index(nil)

          # If a nil element is found, replace it
          if first_nil_index
            item.pickup(self)
            @inventory[first_nil_index] = item
          end
        end

        def drop(item)
          return false if !item
          return false if dead?

          item.drop(self)
          index = @inventory.find_index { |i| i.id == item.id }
          @inventory[index] = nil
          true
        end

        def throw(item, target = nil)
          return false if !item

          thrown = item.throw(self, target)

          if thrown
            index = @inventory.find_index { |i| i.id == item.id }
            @inventory[index] = nil
          end

          thrown
        end

        def use(item, target = nil)
          return false if !item
          return false if dead?

          used = item.use(self, target)

          if used
            index = @inventory.find_index { |i| i.id == item.id }
            @inventory[index] = nil
          end

          used
        end

        def heal(amount)
          return false if dead?
          return false if @health == @max_health

          new_hp_value = @health + amount

          if new_hp_value > @max_health
            new_hp_value = @max_health
          end

          amount_recovered = new_hp_value - @health

          @health = new_hp_value

          amount_recovered
        end

        def take_damage(_attacker, damage)
          @health -= damage
        end

        def health
          @health
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
