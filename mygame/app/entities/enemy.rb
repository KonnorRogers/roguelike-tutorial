require "app/entities/entity"
require "app/entities/mixins/fighter"
require "app/pathfinding/a_star"

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


      include Mixins::Fighter

      attr_accessor :type, :entity_type, :viewed

      RANDOM_MOVEMENTS = [
        :left,
        :right,
        :up,
        :down
      ]

      def initialize(type:, w: 1, h: 1, x: nil, y: nil, **kwargs)
        super(**kwargs)

        @type = type
        @entity_type = :enemy

        @w = w
        @h = h
        @x = x
        @y = y

        @health = 5
        @max_health = 5
        @power = 1
        @defense = 0
        @speed = 1

        @viewed = false

        set_sprite
      end

      def take_damage(damage)
        self.health -= damage

        entity = @engine.scale_for_screen(self.serialize)
        @engine.floating_text.add("#{damage}", entity: entity, color: {r: 255, g: 255, b: 255, a: 255})
      end

      def attack(entity:)
        if entity == @dungeon.player
          entity.take_damage(@power)

          true
        else
          false
        end
      end

      def health=(val)
        super(val)

        if dead?
          set_sprite
          @collideable = false
          @movement_cost = 0
        end
      end

      def take_turn
        # don't try to move if not found by player.
        return false if !@viewed

        return false if dead?

        path = []
        max_move_attempts = 1

        if @viewed
          max_move_attempts = 8
          target = { x: @dungeon.player.x, y: @dungeon.player.y }
          start = { x: @x, y: @y }

          a_star = App::Pathfinding::AStar.new(start: start, target: target, graph: @engine.graph)
          a_star.calc

          # if a path couldn't be calculated, make it move randomly.
          path = a_star.path
        end

        if path.length <= 0
          path = RANDOM_MOVEMENTS.shuffle
        end

        move_attempts = 1
        for direction in path
          did_move = move(@dungeon, direction: direction)
          break if did_move
          break if move_attempts >= max_move_attempts

          move_attempts += 1
        end
      end

      def set_sprite
        sprite = ENEMY_SPRITES[@type]
        @source_x = sprite.source_x
        @source_y = sprite.source_y
        @source_h = sprite.source_h
        @source_w = sprite.source_w
        @path = sprite.path

        if dead?
          @source_x = 0
          @source_y = 102
        end
      end
    end
  end
end
