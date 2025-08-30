module App
  module Entities
    class Entity < SpriteKit::Sprite
      attr_accessor :dungeon, :movement_cost


      def initialize(dungeon:, **kwargs)
        @dungeon = dungeon
        @collideable = true
        @item = false
        @movement_cost = 10
      end

      def collideable?
        !!@collideable
      end

      def item?
        !!@item
      end

      def draw_order
        return 0 if dead?
        return 1 if item?
        return 2
      end
    end
  end
end
