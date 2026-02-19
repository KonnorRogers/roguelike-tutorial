require "app/entities/items/item"

module App
  module Entities
    module Items
      class LightningPotion < Item
        SPRITE = {
          filled: {
            source_x: 0,
            lightning_y: 32,
            source_h: 32,
            source_w: 32,
            path: App::SPRITESHEET_EXTENSIONS_PATH
          },
          transparent: {
            source_x: 0,
            source_y: 0,
            source_h: 32,
            source_w: 32,
            path: App::SPRITESHEET_EXTENSIONS_PATH
          }
        }.freeze

        NAME = "Lightning Potion"

        attr_reader :transparent
        attr_accessor :maximum_range, :damage

        def initialize(damage:, maximum_range:, transparent: false, **kwargs)
          super(**kwargs)
          @maximum_range = maximum_range
          @damage = damage
          @name = NAME
          set_sprite
        end

        def set_sprite
          sprite = SPRITE[:filled]
          if @transparent
            sprite = SPRITE[:transparent]
          end
          @source_x = sprite.source_x
          @source_y = sprite.source_y
          @source_h = sprite.source_h
          @source_w = sprite.source_w
          @path = sprite.path
        end

        def transparent=(bool)
          @transparent = bool
          set_sprite
        end

        def pickup(consumer)
          super(consumer)

          @transparent = true
          set_sprite
        end

        def drop(consumer)
          super(consumer)
          @transparent = false
          set_sprite
        end

        def use(consumer)
          target = nil
          closest_distance = @maximum_range + 1.0

          @engine.dungeon.visible_entities.each do |entity|
            next if entity == consumer
            next unless entity.is_a?(Enemy)
            next if entity.dead?

            distance = consumer.distance_from(x: entity.x, y: entity.y)

            if distance < closest_distance
              target = entity
              closest_distance = distance
            end
          end

          if target
            @engine.game_log.log(
              "A lighting bolt strikes the #{target.type} with a loud thunder, for #{@damage} damage!"
            )
            @engine.floating_text.add("#{@damage}", entity: target, color: {r: 255, g: 0, b: 0, a: 255})
            target.take_damage(consumer, self.damage)
            return true
          end

          false
        end
      end
    end
  end
end
