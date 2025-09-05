require "app/rectangular_room"
require "app/tiles/floor"
require "app/tiles/wall"
require "app/entities/enemy"
require "app/dungeon"

module App
  module Procgen
    def self.generate_dungeon(
      engine:,
      max_rooms:,
      room_min_size:,
      room_max_size:,
      map_width:,
      map_height:,
      max_monsters_per_room:
    )
      dungeon = App::Dungeon.new(w: map_width, h: map_height)
      engine.dungeon = dungeon
      dungeon.player = App::Entities::Player.new(engine: engine)
      player = dungeon.player
      dungeon.entities << player

      # @type [Array<Room>]
      rooms = []

      max_rooms.times do
        # need to use Numeric#rand because Kernel#rand doesn't support ranges in mruby. Numeric#rand is patched by DR.
        room_width = Numeric.rand(room_min_size..room_max_size)
        room_height = Numeric.rand(room_min_size..room_max_size)

        x = Numeric.rand(0..dungeon.w - room_width - 1)
        y = Numeric.rand(0..dungeon.h - room_height - 1)

        # "RectangularRoom" class makes rectangles easier to work with
        new_room = App::RectangularRoom.new(x: x, y: y, w: room_width, h: room_height)

        # Run through the other rooms and see if they intersect with this one.
        if rooms.any? { |other_room| new_room.intersects?(other_room) }
          next # This room intersects, so go to the next attempt.
        end

        # If there are no intersections then the room is valid.

        # Dig out this rooms inner area.
        generate_room(new_room, tiles: dungeon.tiles)

        if rooms.length == 0
          # The first room, where the player starts.
          player.x, player.y = new_room.center
        else # All rooms after the first.
          # Dig out a tunnel between this room and the previous one.
          generate_tunnel(rooms[-1].center, new_room.center, tiles: dungeon.tiles)
        end

        generate_entities_for_room(room: new_room, engine: engine, max_monsters: max_monsters_per_room)

        # Finally, append the new room to the list.
        rooms << new_room
      end


      # Wait to generate walls until the whole dungeon is generated.
      dungeon.walls = generate_walls(dungeon.tiles)

      dungeon.flat_tiles = dungeon.tiles.map { |_, hash| hash.values }.flatten
      dungeon.flat_tiles.concat(dungeon.walls.map { |_, hash| hash.values }.flatten)
      dungeon
    end

    def self.generate_room(room, tiles:)
      room.w.times do |x|
        room.h.times do |y|
          tile = nil

          if !tile
            tile = Tiles::Floor.new(type: :blank)
          end

          tile.x = room.x + x
          tile.y = room.y + y
          tile.w = 1
          tile.h = 1

          tiles[x + room.x] ||= {}
          tiles[x + room.x][y + room.y] = tile
        end
      end
    end

    def self.generate_entities_for_room(room:, engine:, max_monsters:)
      number_of_monsters = Numeric.rand(0..max_monsters)

      number_of_monsters.times do
        inner_x, inner_y = room.inner
        x = Numeric.rand(inner_x)
        y = Numeric.rand(inner_y)

        entity_at_location = engine.dungeon.entities.any? { |entity| entity.x == x && entity.y == y }
        if !entity_at_location
          entity = nil
          if Numeric.rand < 0.8
            # Orc
            entity = App::Entities::Enemy.new(engine: engine, type: :orc)
          else
            # Troll
            entity = App::Entities::Enemy.new(engine: engine, type: :troll)
          end

          entity.x = x
          entity.y = y
          engine.dungeon.entities << entity
        end
      end
    end

    def self.generate_tunnel(tunnel_start, tunnel_end, tiles:)
      prev_x = nil
      prev_y = nil
      Procgen.tunnel_between(tunnel_start, tunnel_end).each do |coords|
        x, y = coords
        tiles[x] ||= {}

        # calc distance between x
        if prev_x && prev_x - x != 0
          # we're going horizontal. Walls need to be above / below.
          # add_tile(App::Tiles::Wall.new(x: x, y: y + 1, type: :brick, direction: :top_middle), tiles: tiles)
          # add_tile(App::Tiles::Wall.new(x: x, y: y - 1, type: :brick, direction: :bottom_middle), tiles: tiles)
        elsif prev_y && prev_y - y != 0
          # we're going vertical. Walls need to be left / right.
          # add_tile(App::Tiles::Wall.new(x: x + 1, y: y, type: :brick, direction: :middle_right), tiles: tiles)
          # add_tile(App::Tiles::Wall.new(x: x - 1, y: y, type: :brick, direction: :middle_left), tiles: tiles)
        end

        tile = App::Tiles::Floor.new(x: x, y: y, type: :blank)
        add_tile(tile, tiles: tiles)

        prev_x = x
        prev_y = y
      end
    end

    def self.add_tile(tile, tiles:)
      tiles[tile.x] ||= {}
      tiles[tile.x][tile.y] = tile
      tile.w = 1
      tile.h = 1
    end

    def self.add_wall(wall, walls:)
      walls[wall.x] ||= {}
      walls[wall.x][wall.y] = wall
      wall.w = 1
      wall.h = 1
    end

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

    def self.generate_walls(tiles)
      walls = {}

      tiles.each do |x, hash|
        right_tile = tiles[x + 1]
        left_tile = tiles[x - 1]

        hash.each do |y, tile|
          center_tile = tiles[x]

          if left_tile == nil
            # Need to find the max_y and do that N times
            add_wall(App::Tiles::Wall.new(x: x - 1, y: y, type: :brick, direction: :middle_middle), walls: walls)
            add_wall(App::Tiles::Wall.new(x: x - 1, y: y + 1, type: :brick, direction: :middle_middle), walls: walls)
            add_wall(App::Tiles::Wall.new(x: x - 1, y: y - 1, type: :brick, direction: :middle_middle), walls: walls)
          end

          if right_tile == nil
            # Need to find the max_y and do that N times
            add_wall(App::Tiles::Wall.new(x: x + 1, y: y, type: :brick, direction: :middle_middle), walls: walls)
            add_wall(App::Tiles::Wall.new(x: x + 1, y: y + 1, type: :brick, direction: :middle_middle), walls: walls)
            add_wall(App::Tiles::Wall.new(x: x + 1, y: y - 1, type: :brick, direction: :middle_middle), walls: walls)
          end


          if left_tile && left_tile[y] == nil
            add_wall(App::Tiles::Wall.new(x: x - 1, y: y, type: :brick, direction: :middle_middle), walls: walls)
          end

          if left_tile && left_tile[y - 1] == nil
            add_wall(App::Tiles::Wall.new(x: x - 1, y: y - 1, type: :brick, direction: :middle_middle), walls: walls)
          end

          if left_tile && left_tile[y + 1] == nil
            add_wall(App::Tiles::Wall.new(x: x - 1, y: y + 1, type: :brick, direction: :middle_middle), walls: walls)
          end

          if right_tile && right_tile[y] == nil
            add_wall(App::Tiles::Wall.new(x: x + 1, y: y, type: :brick, direction: :middle_middle), walls: walls)
          end

          if right_tile && right_tile[y - 1] == nil
            add_wall(App::Tiles::Wall.new(x: x + 1, y: y - 1, type: :brick, direction: :middle_middle), walls: walls)
          end

          if right_tile && right_tile[y + 1] == nil
            add_wall(App::Tiles::Wall.new(x: x + 1, y: y + 1, type: :brick, direction: :middle_middle), walls: walls)
          end

          if center_tile[y + 1] == nil
            add_wall(App::Tiles::Wall.new(x: x, y: y + 1, type: :brick, direction: :middle_middle), walls: walls)
          end

          if center_tile[y - 1] == nil
            add_wall(App::Tiles::Wall.new(x: x, y: y - 1, type: :brick, direction: :middle_middle), walls: walls)
          end
        end
      end
      walls
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
