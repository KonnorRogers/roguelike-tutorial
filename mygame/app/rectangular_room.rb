module App
  class RectangularRoom
    attr_accessor :x, :y, :w, :h, :x2, :y2, :map

    def initialize(x:, y:, w:, h:)
      @w = w
      @x = x
      @y = y
      @h = h

      @x2 = @x + @w
      @y2 = @y + @h
    end

    def center
      center_x = (@x + @x2).idiv(2)
      center_y = (@y + @y2).idiv(2)

      [center_x, center_y]
    end

    def inner
      # Return the inner area of this room as a 2D array index.
      return [(@x + 1)...@x2, (@y + 1)...@y2]
    end

    def intersects?(other_room)
      @x <= other_room.x2 &&
      @x2 >= other_room.x &&
      @y <= other_room.y2 &&
      @y2 >= other_room.y
    end

  end
end
