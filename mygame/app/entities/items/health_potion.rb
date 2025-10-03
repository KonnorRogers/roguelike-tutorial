require "app/entities/items/item"

module App
  module Entities
    module Items
      class HealthPotion < Item
        SPRITE = {
          source_x: 578,
          source_y: 136,
          source_h: 16,
          source_w: 16,
          path: App::SPRITESHEET_PATH
        }.freeze

        attr_accessor :amount

        def initialize(amount:, **kwargs)
          super(**kwargs)
          @amount = amount
          set_sprite
        end

        def set_sprite
          sprite = SPRITE
          @source_x = sprite.source_x
          @source_y = sprite.source_y
          @source_h = sprite.source_h
          @source_w = sprite.source_w
          @path = sprite.path
        end

        def activate(consumer)
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
