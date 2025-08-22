module App
  module Procgen
    # Creates a tunnel between 2 rooms
    def self.tunnel_between(start, finish)
      # Return an L-shaped tunnel between these two points.
      x1, y1 = start
      x2, y2 = finish

      if rand < 0.5  # 50% chance
        # Move horizontally, then vertically.
        corner_x, corner_y = x2, y1
      else
        # Move vertically, then horizontally.
        corner_x, corner_y = x1, y2
      end

      # Generate the coordinates for this tunnel.
      tunnel_coords = []

      # First segment: start to corner
      bresenham_line([x1, y1], [corner_x, corner_y]).each do |x, y|
        tunnel_coords << [x, y]
      end

      # Second segment: corner to end
      bresenham_line([corner_x, corner_y], [x2, y2]).each do |x, y|
        tunnel_coords << [x, y]
      end

      tunnel_coords
    end

    # Bresenham's line algorithm implementation
    def self.bresenham_line(start, finish)
      x0, y0 = start
      x1, y1 = finish

      points = []
      dx = (x1 - x0).abs
      dy = (y1 - y0).abs

      x, y = x0, y0

      x_inc = x1 > x0 ? 1 : -1
      y_inc = y1 > y0 ? 1 : -1
      error = dx - dy

      loop do
        points << [x, y]
        break if x == x1 && y == y1

        if error * 2 > -dy
          error -= dy
          x += x_inc
        end

        if error * 2 < dx
          error += dx
          y += y_inc
        end
      end

      points
    end
  end
end
