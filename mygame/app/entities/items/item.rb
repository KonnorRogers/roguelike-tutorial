require "app/entities/entity.rb"

module App
  module Entities
    module Items
      class Item < Entity
        attr_accessor :name, :targeting_type

        def initialize(...)
          super(...)
          @item = true
          @collideable = false
          @targeting_type = nil # :coordinate | :enemy | nil
        end

        def requires_target?
          return !!@targeting_type
        end

        def pickup(consumer)
          @engine.dungeon.entities.delete(self)

          if consumer == @engine.player
            @engine.game_log.log("You picked up " + self.name)
          end
        end

        def drop(consumer)
          @x = consumer.x
          @y = consumer.y
          # @w = 1
          # @h = 1
          @engine.dungeon.entities << self
        end

        def throw(consumer, target)
        end

        def use(consumer, target = nil)
        end

        def can_use?(consumer, target = nil)
        end

        def dead?
          false
        end
      end
    end
  end
end
