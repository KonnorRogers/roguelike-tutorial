module App
  module Pathfinding
    class Grid
      def initialize(start:, target:, cells:, walls: [])
      end
    end

    class AStar
      def initialize(grid:)
        @grid = grid
        reset
      end

      def reset
        @frontier    = []
        @came_from   = {}
        @path        = []
        @cost_so_far = {}
      end

      def calc
        # Setup the search to start from the star
        @came_from[@grid.start] = nil
        @cost_so_far[@grid.start] = 0
        @frontier << @grid.start

        # Until there are no more cells to explore from or the search has found the target
        until @frontier.empty? or @came_from.key?(@grid.target)
          # Get the next cell to expand from
          current_frontier = @frontier.shift

          # For each of that cells neighbors
          adjacent_neighbors(current_frontier).each do |neighbor|
            # That have not been visited and are not walls
            unless @came_from.key?(neighbor) or @grid.walls.key?(neighbor)
              # Add them to the frontier and mark them as visited
              @frontier << neighbor
              @came_from[neighbor] = current_frontier
              @cost_so_far[neighbor] = @cost_so_far[current_frontier] + 1
            end
          end

          # Sort the frontier so that cells that are in a zigzag pattern are prioritized over those in an line
          # Comment this line and let a path generate to see the difference
          @frontier.sort_by! {| cell | proximity_to_target(cell) }
          @frontier.sort_by! {| cell | @cost_so_far[cell] + heuristic(cell) }
        end
        # If the search found the target
        if @came_from.key?(@grid.target)
          # Calculate the path between the target and star
          calc_path
        end
      end

      # Returns one-dimensional absolute distance between cell and target
      # Returns a number to compare distances between cells and the target
      def heuristic(cell)
        (@grid.target.x - cell.x).abs + (@grid.target.y - cell.y).abs
      end

      # Calculates the path between the target and star for the a_star search
      # Only called when the a_star search finds the target
      def calc_path
        # Start from the target
        endpoint = @grid.target
        # And the cell it came from
        next_endpoint = @came_from[endpoint]

        while endpoint && next_endpoint
          # Draw a path between these two cells and store it
          path = get_path_between(endpoint, next_endpoint)
          @path << path
          # And get the next pair of cells
          endpoint = next_endpoint
          next_endpoint = @came_from[endpoint]
          # Continue till there are no more cells
        end
      end

      def get_path_between(cell_one, cell_two)
        dx = 0
        dy = 0
        if cell_one.x == cell_two.x
          if cell_one.y < cell_two.y
            dy = 1
          else
            dy = -1
          end
        else
          if cell_one.x < cell_two.x
            dx = 1
          else
            dx = -1
          end
        end

        [dx, dy]
      end

      # Returns a list of adjacent cells
      # Used to determine what the next cells to be added to the frontier are
      def adjacent_neighbors(cell)
        neighbors = []

        # Gets all the valid neighbors into the array
        # From southern neighbor, clockwise
        if cell.y != 0
          neighbor = [cell.x, cell.y - 1]
          neighbors << neighbor if neighbor
        end

        if cell.x != 0
          neighbor = [cell.x - 1, cell.y]
          neighbors << neighbor if neighbor
        end

        if cell.y != @grid.height - 1
          neighbor = [cell.x, cell.y + 1]
          neighbors << neighbor if neighbor
        end

        if cell.x != @grid.width - 1
          neighbor = [cell.x + 1, cell.y]
          neighbors << neighbor if neighbor
        end

        neighbors
      end

      # Finds the vertical and horizontal distance of a cell from the star
      # and returns the larger value
      # This method is used to have a zigzag pattern in the rendered path
      # A cell that is [5, 5] from the star,
      # is explored before over a cell that is [0, 7] away.
      # So, if possible, the search tries to go diagonal (zigzag) first
      def proximity_to_target(cell)
        distance_x = (@grid.start.x - cell.x).abs
        distance_y = (@grid.start.y - cell.y).abs

        if distance_x > distance_y
          return distance_x
        else
          return distance_y
        end
      end
    end
  end
end
