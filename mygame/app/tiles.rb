module App
  module Tiles
    ENUM = {
      # Floors
      floor__blank: :floor__blank,

      # Walls
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

    LEGEND = {
      # Floors
      floor__blank: proc { Floor.new(type: :blank) },

      # Walls
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
  end
end
