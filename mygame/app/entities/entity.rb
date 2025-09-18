module App
  module Entities
    class Entity < SpriteKit::Sprite
      attr_accessor :engine, :dungeon, :movement_cost

      def initialize(engine:, **kwargs)
        super(engine: engine, **kwargs)
        @engine = engine
        @dungeon = engine.dungeon
        # @combat_log = engine.combat_log
        @collideable = true
        @item = false
        @movement_cost = 10
      end

      def collideable?
        @collideable
      end

      def item?
        @item
      end

      def serialize
        hash = super
        hash.draw_order = draw_order
        hash
      end

      def draw_order
        return 0 if dead?
        return 1 if item?
        return 2
      end
    end
  end
end
