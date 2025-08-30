require "app/entities/entity"
require "app/entities/mixins/fighter"
module App
  module Entities
    class Player < Entity
      include Mixins::Fighter

      attr_accessor :type, :entity_type, :viewed

      def initialize(...)
        super(...)
        @primitive_marker = :sprite
        @w ||= 1
        @h ||= 1

        @health = 5
        @max_health = 5
        @power = 1
        @defense = 0
        @speed = 1

        @entity_type = :player
        @type = :player
        @viewed = true
        @movement_cost = 0
        set_sprite
      end

      def attack(entity:)
        if entity.is_a?(Enemy)
          entity.health -= @power
          true
        else
          false
        end
      end

      def health=(val)
        super(val)
        set_sprite
      end

      def set_sprite
        if dead?
          @source_x = 391
          @source_y = 204
        else
          @source_x = 306
          @source_y = 204
        end

        @source_h = 16
        @source_w = 16
        @path = App::SPRITESHEET_PATH
      end
    end
  end
end
