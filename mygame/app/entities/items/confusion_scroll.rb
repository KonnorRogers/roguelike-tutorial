require "app/entities/items/item"

module App
  module Entities
    module Items
      class ConfusionScroll < Item
        SPRITE = {
          transparent: {
            source_x: 32,
            source_y: 0,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_EXTENSIONS_PATH
          }
        }.freeze

        NAME = "Confusion Scroll"

        def initialize(engine:, max_turns: 4)
          @engine = engine
          @max_turns = max_turns
        end

        attr_accessor :engine, :max_turns

        def initialize(engine:, max_turns:, **kwargs)
          super(engine: engine, **kwargs)
          @engine = engine
          @max_turns = max_turns
          @name = NAME
          set_sprite
        end

        def set_sprite
          sprite = SPRITE[:transparent]
          @source_x = sprite.source_x
          @source_y = sprite.source_y
          @source_h = sprite.source_h
          @source_w = sprite.source_w
          @path = sprite.path
        end

        def pickup(consumer)
          super(consumer)

          set_sprite
        end

        def drop(consumer)
          super(consumer)
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

