module App
  module Pathfinding
    class Graph
      attr_accessor :cells, :walls, :height, :width, :entities

      def initialize(cells:, entities:, walls: [])
        @cells = cells
        @entities = entities
        @walls = walls
        @height = @cells.map { |_, hash| hash.keys }.flatten.max
        @width = @cells.keys.max
      end
    end

    class AStar
      attr_accessor :frontier, :came_from, :path, :cost_so_far

      def initialize(start:, target:, graph:)
        @start = start
        @target = target
        @graph = graph
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
        @came_from[@start] = nil
        @cost_so_far[@start] = 0
        @frontier << @start

        max_distance = 30
        distance = 0

        entity_locations = {}

        Array(@graph.entities).each do |entity|
          next if entity.dead?

          entity_locations["#{entity.x},#{entity.y}"] = entity
        end

        # Until there are no more cells to explore from or the search has found the target
        until @frontier.empty? or @came_from.key?(@target) or distance > max_distance
          # Get the next cell to expand from
          current_frontier = @frontier.shift

          # For each of that cells neighbors
          Array(adjacent_neighbors(current_frontier)).each do |neighbor|
            # That have not been visited and are not walls
            unless @came_from.key?(neighbor) # or @grid.walls.key?(neighbor)
              # Add them to the frontier and mark them as visited
              @frontier << neighbor
              @came_from[neighbor] = current_frontier
              tile = @graph.cells[neighbor.x][neighbor.y]

              extra_cost = 0
              entity = entity_locations["#{neighbor.x},#{neighbor.y}"]

              if entity
                extra_cost = entity.movement_cost
              end

              @cost_so_far[neighbor] = @cost_so_far[current_frontier] + tile.movement_cost + extra_cost
            end
          end

          # Sort the frontier so that cells that are in a zigzag pattern are prioritized over those in an line
          # Comment this line and let a path generate to see the difference
          @frontier = Array(@frontier).sort_by do |cell|
            # cost_so_for + greedy_heuristic is weighted way heavier than proximity_to_start
            proximity_to_start(cell) + ((@cost_so_far[cell] + greedy_heuristic(cell)) * 1_000)
          end

          distance += 1
        end

        # If the search found the target
        if @came_from.key?(@target)
          # Calculate the path between the target and star
          calc_path
        end
        self
      end

      # Returns one-dimensional absolute distance between cell and target
      # Returns a number to compare distances between cells and the target
      def greedy_heuristic(cell)
        (@target.x - cell.x).abs + (@target.y - cell.y).abs
      end


      # Calculates the path between the target and star for the a_star search
      # Only called when the a_star search finds the target
      def calc_path
        # Start from the target
        endpoint = @target
        # And the cell it came from
        next_endpoint = @came_from[endpoint]

        while endpoint && next_endpoint
          # Draw a path between these two cells and store it
          # path = get_path_between(endpoint, next_endpoint)
          path = get_path_direction(endpoint, next_endpoint)
          @path << path
          # And get the next pair of cells
          endpoint = next_endpoint
          next_endpoint = @came_from[endpoint]
          # Continue till there are no more cells
        end
      end
      # Returns a list of adjacent cells
      # Used to determine what the next cells to be added to the frontier are
      def adjacent_neighbors(cell)
        neighbors = []

        # Gets all the valid neighbors into the array
        # From southern neighbor, clockwise
        if cell.y > 0
          x = cell.x
          y = cell.y - 1
          tile = @graph.cells[x]
          tile = tile[y] if tile
          neighbors << {x: x, y: y} if tile
        end

        if cell.x > 0
          x = cell.x - 1
          y = cell.y
          tile = @graph.cells[x]
          tile = tile[y] if tile
          neighbors << {x: x, y: y} if tile
        end

        if cell.y < @graph.height - 1
          x = cell.x
          y = cell.y + 1
          tile = @graph.cells[x]
          tile = tile[y] if tile
          neighbors << {x: x, y: y} if tile
        end

        if cell.x < @graph.width - 1
          x = cell.x + 1
          y = cell.y
          tile = @graph.cells[x]
          tile = tile[y] if tile
          neighbors << {x: x, y: y} if tile
        end

        neighbors
      end

      # Finds the vertical and horizontal distance of a cell from the star
      # and returns the larger value
      # This method is used to have a zigzag pattern in the rendered path
      # A cell that is [5, 5] from the star,
      # is explored before over a cell that is [0, 7] away.
      # So, if possible, the search tries to go diagonal (zigzag) first
      def proximity_to_start(cell)
        distance_x = (@start.x - cell.x).abs
        distance_y = (@start.y - cell.y).abs

        if distance_x > distance_y
          return distance_x
        else
          return distance_y
        end
      end

      # original algorithm
      # def get_path_between(cell_one, cell_two)
      #   # actual x / y
      #   # x = cell_one.x + (cell_two.x - cell_one.x)
      #   # y = cell_one.y + (cell_two.y - cell_one.y)

      #   diff_x = cell_one.x - cell_two.x
      #   diff_y = cell_one.y - cell_two.y

      #   {x: diff_x, y: diff_y}
      # end

      def get_path_direction(cell_one, cell_two)
        diff_x = cell_one.x - cell_two.x
        diff_y = cell_one.y - cell_two.y

        if diff_x == 1
          :right
        elsif diff_x == -1
          :left
        elsif diff_y == 1
          :up
        elsif diff_y == -1
          :down
        end
      end
    end
  end
end
