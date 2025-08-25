require "app/entities/entity"
require "app/entities/mixins/fighter"
module App
  module Entities
    class Player < Entity
      prepend Mixins::Fighter

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
        set_sprite
      end

      def set_sprite
        @source_x = 306
        @source_y = 204
        @source_h = 16
        @source_w = 16
        @path = App::SPRITESHEET_PATH
      end
    end
  end
end
