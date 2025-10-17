require "app/entities/entity.rb"

module App
  module Entities
    module Items
      class Item < Entity
        attr_accessor :name

        def initialize(...)
          super(...)
          @item = true
          @collideable = false
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
          @engine.dungeon.entities << self
        end

        def throw(consumer)
        end

        def use(consumer)
        end

        def dead?
          false
        end
      end
    end
  end
end
