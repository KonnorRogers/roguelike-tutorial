module App
  module Enitities
    class Enemy < SpriteKit::Sprite
      ENEMY_SPRITES = {
        scorpion: {
          source_x: 408,
          source_y: 272,
          source_h: 16,
          source_w: 16,
        }
      }
      ENEMY_SPRITES.each { |_key, hash| hash[:path] = App::SPRITESHEET_PATH }

      def initialize(enemy_type:, **kwargs)
        super(**kwargs)

        @type = :enemy
        @enemy_type = enemy_type
        set_sprite
      end

      def set_sprite
        sprite = ENEMY_SPRITES[@enemy_type]
        @source_x = sprite.source_x
        @source_y = sprite.source_y
        @source_h = sprite.source_h
        @source_w = sprite.source_w
        @path = sprite.path
      end
    end
  end
end
