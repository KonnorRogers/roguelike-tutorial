require "app/tiles/wall"
require "app/tiles/floor"
require "app/room"
require "app/procgen"

module App
  class Map
    attr_accessor :w, :h, :tiles, :flat_tiles

    def initialize(w:, h:)
      @w = w
      @h = h

      @tiles = []
      generate_rooms
      generate_tunnels
      @flat_tiles = @tiles.flatten.compact
    end

    def collision?(rect)
      collisions(rect).length > 0
    end

    def collisions(rect)
      collideable_tiles = @flat_tiles.select { |tile| tile.is_a?(Tiles::Wall) }
      Geometry.find_all_intersect_rect(rect, collideable_tiles)
    end

    def generate_rooms
      @rooms = 2.times.map do |i|
        App::Room.new(map: self, x: i * 30, y: i * 4, w: 20, h: 20)
      end
    end

    def generate_tunnels
      Procgen.tunnel_between(@rooms[0].center, @rooms[1].center).each do |ary|
        x, y = ary
        putz x, y
        @tiles[x] ||= []
        tile = App::Tiles::Floor.new(type: :blank)
        tile.x = (x * TILE_SIZE)
        tile.y = (y * TILE_SIZE)
        tile.w = TILE_SIZE
        tile.h = TILE_SIZE
        @tiles[x][y] = tile
      end
    end
  end
end
