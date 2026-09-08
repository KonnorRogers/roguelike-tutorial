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
          @maximum_range = 6
          @requires_target = true
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

        def use(consumer, target)
          target = nil
          closest_distance = @maximum_range + 1.0

          @engine.dungeon.visible_entities.find { |e| e == target }

          if target
            @engine.game_log.log(
              "#{target.type} is confused!"
            )
            @engine.floating_text.add("Confused!", entity: target, color: {r: 0, g: 0, b: 255, a: 255})
            target.take_damage(consumer, self.damage)
            return true
          end

          false
        end
      end
    end
  end
end

