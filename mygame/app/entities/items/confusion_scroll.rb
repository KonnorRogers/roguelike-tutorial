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
          @maximum_range = 8
          @targeting_type = :enemy
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

        def can_use?(consumer, target)
          return false if !target

          distance = consumer.distance_from(x: target.x, y: target.y)

          return false if distance > @maximum_range
          return false if !target.is_a?(Enemy)

          true
        end

        def use(consumer, target)
          return false if !can_use?(consumer, target)

          if target
            @engine.game_log.log(
              "#{target.type} is confused!"
            )

            target.confused = true
            entity = @engine.scale_for_screen(target.serialize)
            @engine.floating_text.add("Confused!!", entity: entity, color: {r: 0, g: 0, b: 255, a: 255})
            return true
          end

          false
        end
      end
    end
  end
end

