module App
  module Tiles
    class Wall < SpriteKit::Sprite
      def self.create_from_key(key)
        WALL_LEGEND[key].call
      end

      WALL_ENUM = {
        wall__brick0: :wall__brick0,
        wall__brick1: :wall__brick1,
        wall__brick2: :wall__brick2,
        wall__brick3: :wall__brick3,
        wall__brick4: :wall__brick4,
        wall__brick5: :wall__brick5,
        wall__brick6: :wall__brick6,
        wall__brick7: :wall__brick7,
        wall__brick8: :wall__brick8
      }.freeze

      WALL_LEGEND = {
        wall__brick0: proc { Wall.new(direction: :bottom_left, type: :brick) },
        wall__brick1: proc { Wall.new(direction: :bottom_middle, type: :brick) },
        wall__brick2: proc { Wall.new(direction: :bottom_right, type: :brick) },
        wall__brick3: proc { Wall.new(direction: :middle_left, type: :brick) },
        wall__brick4: proc { Wall.new(direction: :middle_middle, type: :brick) },
        wall__brick5: proc { Wall.new(direction: :middle_right, type: :brick) },
        wall__brick6: proc { Wall.new(direction: :top_left, type: :brick) },
        wall__brick7: proc { Wall.new(direction: :top_middle, type: :brick) },
        wall__brick8: proc { Wall.new(direction: :top_right, type: :brick) }
      }.freeze

      WALL_SPRITES = {
        brick: {
          bottom_left: {
            source_x: 306,
            source_y: 323,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          middle_left: {
            source_x: 306,
            source_y: 340,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          top_left: {
            source_x: 306,
            source_y: 357,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          bottom_middle: {
            source_x: 323,
            source_y: 323,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          middle_middle: {
            source_x: 323,
            source_y: 340,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          top_middle: {
            source_x: 323,
            source_y: 357,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          bottom_right: {
            source_x: 340,
            source_y: 323,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          middle_right: {
            source_x: 340,
            source_y: 340,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          },
          top_right: {
            source_x: 340,
            source_y: 357,
            source_h: 16,
            source_w: 16,
            path: App::SPRITESHEET_PATH
          }
        }
      }.freeze

      attr_accessor :type, :direction

      def initialize(direction:, type:, **kwargs)
        super(**kwargs)

        @direction = direction
        @type = type
        update_self
      end

      def collideable?
        true
      end

      def blocks_sight?
        true
      end

      def update_self
        sprite = WALL_SPRITES[@type][@direction]
        @source_x = sprite.source_x
        @source_y = sprite.source_y
        @source_h = sprite.source_h
        @source_w = sprite.source_w
        @path = sprite.path
      end
    end
  end
end
