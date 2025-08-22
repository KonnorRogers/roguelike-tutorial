module App
  class Room
    attr_accessor :x, :y, :w, :h, :x2, :y2, :map

    def initialize(x:, y:, w:, h:, map:)
      @w = w
      @x = x
      @y = y
      @h = h

      @x2 = @x + @w
      @y2 = @y + @h
      @map = map
      generate
    end

    def center
      center_x = (@x + @x2).idiv(2)
      center_y = (@y + @y2).idiv(2)

      [center_x, center_y]
    end

    def inner
      # Return the inner area of this room as a 2D array index.
      return (@x + 1)...@x2, (@y + 1)...@y2
    end

    def intersects?(other_room)
      @x <= other_room.x2 &&
      @x2 >= other_room.x &&
      @y <= other_room.y2 &&
      @y2 >= other_room.y
    end

    def generate
      @w.times do |x|
        @h.times do |y|
          tile = nil
          if x == 0 && y == 0
            # bottom left
            tile = Tiles::Wall.new(type: :brick, direction: :bottom_left)
          elsif x == 0 && y < @h - 1
            # middle left
            tile = Tiles::Wall.new(type: :brick, direction: :middle_left)
          elsif x == 0 && y == @h - 1
            # top left
            tile = Tiles::Wall.new(type: :brick, direction: :top_left)
          elsif (x > 0 && x < @w - 1) && y == 0
            # bottom middle
            tile = Tiles::Wall.new(type: :brick, direction: :bottom_middle)
          elsif x == @w - 1 && y == 0
            # bottom right
            tile = Tiles::Wall.new(type: :brick, direction: :bottom_right)
          elsif x == @w - 1 && y == @h - 1
            # top right
            tile = Tiles::Wall.new(type: :brick, direction: :top_right)
          elsif (x >= 0 && x < @w - 1) && y == @h - 1
            # top middle
            tile = Tiles::Wall.new(type: :brick, direction: :top_middle)
          elsif x == @w - 1 && y < @h - 1
            # middle right
            tile = Tiles::Wall.new(type: :brick, direction: :middle_right)
          else
          end

          if !tile
            tile = Tiles::Floor.new(type: :blank)
          end

          tile.x = (@x * TILE_SIZE) + (x * TILE_SIZE)
          tile.y = (@y * TILE_SIZE) + (y * TILE_SIZE)
          tile.w = TILE_SIZE
          tile.h = TILE_SIZE

          @map.tiles[x + @x] ||= []
          @map.tiles[x + @x][y + @y] = tile
        end
      end
    end
  end
end
