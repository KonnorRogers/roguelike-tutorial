require "app/entities/entity"
require "app/entities/mixins/fighter"

module App
  module Entities
    class Enemy < Entity
      ENEMY_SPRITES = {
        scorpion: {
          source_x: 408,
          source_y: 272,
          source_h: 16,
          source_w: 16,
        },
        orc: {
          source_x: 425,
          source_y: 204,
          source_h: 16,
          source_w: 16,
        },
        troll: {
          source_x: 493,
          source_y: 323,
          source_h: 16,
          source_w: 16,
        },
      }
      ENEMY_SPRITES.each { |_key, hash| hash[:path] ||= App::SPRITESHEET_PATH }


      prepend Mixins::Fighter

      attr_accessor :type, :entity_type

      def initialize(type:, w: 1, h: 1, x: nil, y: nil, **kwargs)
        super(**kwargs)

        @type = type
        @entity_type = :enemy
        set_sprite

        @w = w
        @h = h
        @x = x
        @y = y

        @health = 5
        @max_health = 5
        @power = 1
        @defense = 0
        @speed = 1
      end

      def take_turn
        puts("The #{self.type} wonders when it will get to take a real turn.")
      end

      def set_sprite
        sprite = ENEMY_SPRITES[@type]
        @source_x = sprite.source_x
        @source_y = sprite.source_y
        @source_h = sprite.source_h
        @source_w = sprite.source_w
        @path = sprite.path
      end
    end
  end
end
