require "app/tiles/wall"

module App
  class Dungeon
    attr_accessor :w, :h, :tiles, :flat_tiles, :explored_tiles, :visible_tiles, :player, :entities, :visible_entities

    def initialize(w:, h:, player:)
      @w = w
      @h = h

      @player = player
      @entities = [
        @player
      ]
      @visible_entities = []
      @tiles = []
      @flat_tiles = []
      @explored_tiles = []
    end

    def collision?(rect)
      collisions(rect).length > 0
    end

    def in_bounds?(rect)
      Geometry.find_all_intersect_rect(rect, @flat_tiles).length > 0
    end

    def out_of_bounds?(rect)
      !in_bounds?(rect)
    end

    def collisions(rect)
      collideable_tiles = (@flat_tiles + @entities).select(&:collideable?)
      Geometry.find_all_intersect_rect(rect, collideable_tiles)
    end

    def update_field_of_view
      view_distance = 4
      field_of_view = {
        x: @player.x - view_distance,
        y: @player.y - view_distance,
        w: @player.w + view_distance * 2,
        h: @player.h + view_distance * 2,
      }

      visible_tiles = Geometry.find_all_intersect_rect(field_of_view, @flat_tiles)
      visible_entities = Geometry.find_all_intersect_rect(field_of_view, @entities)
      @explored_tiles.concat(visible_tiles)
      @explored_tiles.uniq!
      @visible_tiles = visible_tiles
      @visible_entities = visible_entities
    end
  end
end
