require "app/entities/items/item"

module App
  module Entities
    module Items
      class HealthPotion < Item
        SPRITE = {
          filled: {
            source_x: 578,
            source_y: 136,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          transparent: {
            source_x: 578,
            source_y: 136,
            source_h: 16,
            source_w: 16,
            path: "sprites/kenney_1-bit-pack/tilesheet/colored-transparent.png"
          }
        }.freeze

        NAME = "Health Potion"

        attr_reader :transparent
        attr_accessor :amount

        def initialize(amount:, transparent: false, **kwargs)
          super(**kwargs)
          @amount = amount
          @transparent = transparent
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

        def use(consumer)
          amount_recovered = consumer.heal(self.amount)

          if amount_recovered > 0
            @engine.floating_text.add("#{amount_recovered}", entity: entity, color: {r: 0, g: 255, b: 0, a: 255})
            @engine.game_log.log("You recovered #{amount_recovered}", type: :recovered)
            self.engine.message_log.add_message(
                "You consume the Health Potion, and recover #{amount_recovered} HP!",
                :hp_recover,
            )
          end
        end
      end
    end
  end
end
