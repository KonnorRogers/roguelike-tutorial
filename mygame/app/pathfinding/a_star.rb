module App
  module Pathfinding
    class PriorityQueue
      attr_accessor :ary

      def initialize &has_priority_block
        @ary = []
        @has_priority_block = has_priority_block
      end

      def heapify n, i
        top_priority = i
        l = 2 * i + 1
        r = 2 * i + 2

        top_priority = l if l < n && @has_priority_block.call(@ary[l], @ary[top_priority])
        top_priority = r if r < n && @has_priority_block.call(@ary[r], @ary[top_priority])

        return if top_priority == i

        @ary[i], @ary[top_priority] = @ary[top_priority], @ary[i]
        heapify n, top_priority
      end

      def insert n
        @ary.push_back n
        current = @ary.length - 1
        while current > 0
          parent = (current - 1) >> 1
          if @has_priority_block.call(@ary[current], @ary[parent])
            @ary[current], @ary[parent] = @ary[parent], @ary[current]
            current = parent
          else
            break
          end
        end
      end

      def extract
        l = @ary.length
        @ary[0], @ary[l - 1] = @ary[l - 1], @ary[0]
        result = @ary.pop_back
        heapify @ary.length, 0 if 0 < @ary.length
        result
      end

      def empty?
        @ary.empty?
      end
    end

    class Graph
      attr_accessor :cells, :walls, :height, :width, :entities

      def initialize(cells:, entities:, walls: {})
        @cells = cells
        @entities = entities
        @walls = walls
        @height = @cells.map { |_, hash| hash.keys }.flatten.max
        @width = @cells.keys.max
      end
    end

    class AStar
      attr_accessor :frontier, :came_from, :path, :cost_so_far

      def initialize(start:, target:, graph:, max_distance: 30)
        @start = start
        @target = target
        @graph = graph
        # It can get expensive on large maps to do path finding. If we're more than 30 tiles deep, just cut it off.
        @max_distance = max_distance
        reset
      end

      def reset
        @frontier = PriorityQueue.new do |a, b|
          a_result = proximity_to_start(a) + ((@cost_so_far[a] + greedy_heuristic(a)) * 1_000)
          b_result = proximity_to_start(b) + ((@cost_so_far[b] + greedy_heuristic(b)) * 1_000)
          (a_result <=> b_result) == -1
        end

        @came_from   = {}
        @path        = []
        @cost_so_far = {}
      end

      def calc
        # Setup the search to start from the star
        @came_from[@start] = nil
        @cost_so_far[@start] = 0
        @frontier.insert(@start)

        distance = 0

        entity_locations = {}

        Array.each(@graph.entities) do |entity|
          next if entity.item?
          next if entity.dead?

          entity_locations["#{entity.x},#{entity.y}"] = entity
        end

        # Until there are no more cells to explore from or the search has found the target
        until @frontier.empty? or @came_from.key?(@target) or distance > @max_distance
          # Get the next cell to expand from
          current_frontier = @frontier.extract
          new_locations = adjacent_neighbors(current_frontier)

          # For each of that cells neighbors
          Array.each(new_locations) do |neighbor|
            # That have not been visited and are not walls
            unless @came_from.key?(neighbor) or @graph.walls.key?(neighbor)
              @came_from[neighbor] = current_frontier
              tile = @graph.cells[neighbor.x][neighbor.y]

              extra_cost = 0
              entity = entity_locations["#{neighbor.x},#{neighbor.y}"]

              if entity
                extra_cost = entity.movement_cost
              end

              # Mark cost_so_far before inserting into the frontier, otherwise we get a nil issue.
              @cost_so_far[neighbor] = @cost_so_far[current_frontier] + tile.movement_cost + extra_cost

              # Add them to the frontier and mark them as visited
              @frontier.insert(neighbor)
            end
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
