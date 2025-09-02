module App
  # Used to log events such as picking things up, attacking enemies, etc.
  class GameLog
    attr_accessor :max_history_size

    def initialize
      @max_history_size = 500
      @log_items = []
    end

    def add(item)
    end
  end
end
