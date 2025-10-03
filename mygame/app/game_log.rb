module App
  # Used to log events such as picking things up, attacking enemies, etc.
  class GameLog
    attr_accessor :max_history_size, :displayed_items, :size_px

    attr_sprite

    TYPE_TO_COLOR = {
      info: { r: 255, b: 255, g: 255, a: 255 },
      player_hit: { r: 255, b: 0, g: 0, a: 255 },
      enemy_hit: { r: 255, b: 255, g: 255, a: 255 },
      hp_recover: { r: 0, b: 0, g: 255 }
    }

    def initialize
      @max_history_size = 500
      @log_items = []
      @displayed_items = []
      @log_start = 0
      @log_length = 0

      @y = 20
      @x = Grid.w / 2
      @anchor_x = 0.5
      @size_px = 24
      @h = @size_px * 5
      @w = 400
      @path = :game_log
      @primitive_marker = :sprite
    end

    def render_target(outputs)
      outputs[@path].tap do |rt|
        rt.background_color = [0, 0, 0, 128]
        rt.w = @w
        rt.h = @h
      end
    end

    def render(draw_buffer)
      render_target(draw_buffer.outputs)
      idx = 0
      draw_buffer[@path].concat(@displayed_items.map do |item|
        hash = item.merge({
          y: 0,
          x: 0,
          anchor_y: idx,
          anchor_x: 0,
        })
        idx -= 1
        hash
      end)
    end

    def update
      @displayed_items = @log_items.slice(@log_start, @log_length)
      nil
    end

    def log(message, type: :info)
      @log_items.unshift({
        text: message,
        type: type,
        size_px: @size_px,
        **TYPE_TO_COLOR.fetch(type, TYPE_TO_COLOR[:info]),
        primitive_marker: :label,
      })

      if @log_items.length > @max_history_size
        @log_items.pop
      end

      @log_start = @log_items.length - 5

      if @log_start < 0
        @log_start = 0
      end

      @log_length = @log_items.length

      update
    end
  end
end
