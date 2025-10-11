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
        @power = 400
        @defense = 0
        @speed = 1

        @entity_type = :player
        @type = :player
        @viewed = true
        @movement_cost = 0
        @max_inventory_size = 25
        @inventory = Array.new(@max_inventory_size)
        set_sprite
      end

      def attack(entity:)
        if entity.is_a?(Enemy)
          entity.take_damage(self, @power)
          true
        else
          false
        end
      end

      def take_damage(attacker, damage)
        self.health -= damage

        entity = @engine.scale_for_screen(self.serialize)
        @engine.floating_text.add("#{damage}", entity: entity, color: {r: 255, g: 0, b: 0, a: 255})
        @engine.game_log.log("#{attacker.type} hit you for #{damage}", type: :player_hit)
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
