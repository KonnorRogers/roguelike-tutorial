module App
  class FloatingText
    def initialize(draw_buffer:, target:)
      @draw_buffer = draw_buffer
      @target = target
      @queue = {}

      @animation_delay = 0
      @animation_duration = 60 * 3 # 3 seconds
      @y_shift = 16
    end

    def add(text, entity:, offset_y: 16, color: {r: 255, b: 255, g: 255, a: 255}, **kwargs)
      # how much above the entity to show text.
      x = entity.x + (entity.w / 2)
      size_px = kwargs[:size_px] || 32
      y = entity.y + entity.h + size_px
      label = {
        **color,
        x: x,
        y: y,
        text: text,
        primitive_marker: :label,
        scale_quality: 2,
        size_px: size_px,
        **kwargs,

        anchor_x: 0.5,
        # anchor_y: 0.5,
      }

      key = Kernel.tick_count
      @queue[key] ||= []
      final_label = yield label if block_given?
      final_label ||= label
      @queue[key] << final_label
      final_label
    end

    # We have a draw to delay until the end to render after entities so it appears above.
    def flush
      @queue.each do |key, value|
        ary = @queue[key]
        perc = Easing.smooth_start(start_at: key,
                                   end_at: key + @animation_duration,
                                   tick_count: Kernel.tick_count
                                   )

        ary.each do |hash|
          hash.a = hash.a - (hash.a * perc)
          hash.y = hash.y + (@y_shift * perc)
        end
        @draw_buffer.add(ary, target: @target)
      end

      @queue.delete_if { |key, _value| Kernel.tick_count > (key + @animation_duration)  }
    end
  end
end
