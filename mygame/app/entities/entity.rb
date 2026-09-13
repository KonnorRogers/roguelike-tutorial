module App
  module Entities
    class Entity < SpriteKit::Sprite
      STATUS_SPRITES = {
        confused: {
          source_x: 646,
          source_y: 136,
          source_h: 16,
          source_w: 16,
          path: "sprites/kenney_1-bit-pack/tilesheet/colored-transparent.png"
        },
        paralyzed: {
        },
        poisoned: {
        },
        stunned: {}
      }

      STATUSES = %i[confused paralyzed poisoned stunned].freeze

      attr_accessor :engine, :dungeon, :movement_cost, :viewed
      attr_accessor :center_x, :center_y, :center

      def initialize(engine:, **kwargs)
        super(engine: engine, **kwargs)
        @engine = engine
        @dungeon = engine.dungeon
        # @combat_log = engine.combat_log
        @collideable = true
        @movement_cost = 10
        @viewed = false
        @item = false
      end

      # Return the distance between the current entity and the given (x, y) coordinate.
      def distance_from(x:, y:)
        Math.sqrt((x - @x) ** 2 + (y - @y) ** 2)
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
        # hash.delete(:engine)
        hash
      end

      def prefab
        [
          self
      ].concat(status_icons).compact
      end

      def icon(sprite)
        return nil if !@x || !@y || !@h || !@h
        {
          x: @x,
          y: @y + @h + 4,
          w: 32,
          h: 32,
          draw_order: 3,
          **sprite
        }
      end

      def status_icons
        icons = []

        # STATUSES.each do |status|
          # icons << icon(STATUS_SPRITES[status])
        # end
        icons << icon(STATUS_SPRITES[:confused])

        icons
      end

      def draw_order
        return 0 if dead?
        return 1 if item?
        return 2
      end
    end
  end
end
