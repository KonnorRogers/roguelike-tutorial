require "app/tiles/wall"
require "app/entities/player"
require "app/procgen"

module App
  class FieldOfView
    # Multipliers for transforming coordinates into other octants
    MULT = [
      [1,  0,  0, -1, -1,  0,  0,  1],
      [0,  1, -1,  0,  0, -1,  1,  0],
      [0,  1,  1,  0,  0, -1, -1,  0],
      [1,  0,  0,  1, -1,  0,  0, -1],
    ]

    attr_accessor :tiles, :walls, :entities, :visible_tiles, :visible_entities, :explored_tiles

    def initialize(tiles:, walls:, entities:, explored_tiles:)
      @tiles = tiles
      @walls = walls
      @entities = entities
      @explored_tiles = explored_tiles
      @visible_tiles = []
      @visible_entities = []
    end

    # Determines which co-ordinates on a 2D grid are visible
    # from a particular co-ordinate.
    # start_x, start_y: center of view
    # radius: how far field of view extends
    def update(start_x, start_y, radius)
      light(start_x, start_y)
      8.times do |i|
        cast_light(start_x, start_y, 1, 1.0, 0.0, radius,
                  MULT[0][i], MULT[1][i],
                  MULT[2][i], MULT[3][i], 0)
      end
    end


    # Required method for shadowcasting: returns true if tile blocks view
    def light_blocked?(x, y)
      tile = find_tile_or_wall(x, y)
      return true if !tile  # out of bounds blocks view
      tile.blocks_sight?
    end

    # Required method for shadowcasting: marks tile as visible
    def light(x, y)
      tile = find_tile_or_wall(x, y)
      return if !tile  # skip if out of bounds
      handle_visible_tile(tile)
    end

    # Recursive light-casting function
    def cast_light(cx, cy, row, light_start, light_end, radius, xx, xy, yx, yy, id)
      return if light_start < light_end

      radius_sq = radius * radius

      (row..radius).each do |j|
        dx = -j - 1
        dy = -j
        light_blocked = false

        while dx <= 0
          dx += 1

          # Translate the dx, dy co-ordinates into map co-ordinates
          mx = cx + dx * xx + dy * xy
          my = cy + dx * yx + dy * yy

          # l_slope and r_slope store the slopes of the left and right
          # extremities of the square we're considering:
          slope = 0.5
          left_slope = (dx-slope) / (dy+slope)
          right_slope = (dx+slope) / (dy-slope)

          if light_start < right_slope
            next
          elsif light_end > left_slope
            break
          else
            # Our light beam is touching this square; light it
            light(mx, my) if (dx*dx + dy*dy) < radius_sq

            if light_blocked
              # We've scanning a row of light_blocked squares
              if light_blocked?(mx, my)
                new_start = right_slope
                next
              else
                light_blocked = false
                light_start = new_start
              end
            else
              if light_blocked?(mx, my) and j < radius
                # This is a blocking square, start a child scan
                light_blocked = true
                cast_light(cx, cy, j+1, light_start, left_slope, radius,
                          xx, xy, yx, yy, id+1)
                new_start = right_slope
              end
            end
          end
        end # while dx <= 0

        break if light_blocked
      end # (row..radius).each
    end

    def find_tile_or_wall(x, y)
      tile = @tiles[x]
      tile = tile[y] if tile

      if !tile
        tile = @walls[x]
        tile = tile[y] if tile
      end

      tile
    end

    def handle_visible_tile(tile)
      @visible_tiles << tile
      @explored_tiles[tile] = tile if !@explored_tiles.has_key?(tile)

      @entities.each do |entity|
        # is_visible = entity.x ..(entity.x + entity.w)).include?(tile.x + tile.w) && (entity.y..(entity.y + entity.h)).include?(tile.y + tile.h)
        is_visible = entity.x == tile.x && entity.y == tile.y

        if is_visible
          entity.viewed = true
          @visible_entities << entity
        end
      end
    end
  end

  class Dungeon
    attr_accessor :w, :h, :tiles, :walls, :flat_tiles, :explored_tiles, :visible_tiles, :player, :entities, :visible_entities, :graph

    def initialize(w:, h:)
      @w = w
      @h = h

      @entities = []
      @visible_entities = []

      # since we use `hash[k][v]` we don't wanna fill bogus spots with `nil`
      @tiles = {}
      @walls = {}
      @flat_tiles = []
      @explored_tiles = {}
    end

    def create_field_of_view
      @field_of_view = FieldOfView.new(
        tiles: @tiles,
        walls: @walls,
        entities: @entities,
        explored_tiles: @explored_tiles
      )
    end

    def collision?(rect)
      collisions(rect).length > 0
    end

    def in_bounds?(rect)
      collision = @tiles[rect.x]
      collision = collision[rect.y] if collision
      collision != nil
    end

    def out_of_bounds?(rect)
      !in_bounds?(rect)
    end

    def collisions(rect)
      collideable_tiles = (@flat_tiles + @entities.reject { |e| e == rect }).select(&:collideable?)
      collideable_tiles.select { |tile| tile.x == rect.x && tile.y == rect.y }
    end

    def update_field_of_view
      @visible_entities = []
      @visible_tiles = []

      @field_of_view.visible_tiles = @visible_tiles
      @field_of_view.visible_entities = @visible_entities

      return if !player

      # radius of 4 (same as your max_distance)
      @field_of_view.update(player.x, player.y, 4)
    end
  end
end

