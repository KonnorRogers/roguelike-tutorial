
module App
  module Ui
    class ItemMenu < SpriteKit::Sprite
      attr_accessor :open, :item, :rendered_buttons, :item_index

      SAFE_X_INSET = 50
      SAFE_Y_INSET = 50

      def initialize(open: false, item: nil, w: 300, h: 300, **kwargs)
        @open = open
        @item = item
        @item_index = nil
        @rendered_buttons = {
          drop: nil,
          use: nil,
          throw: nil
        }
        @w = w
        @h = h
        @r = 64
        @g = 64
        @b = 64
        @a = 255
      end

      def render
        @w = 300
        @h = 300
        @y = (@item.y + @item.h).clamp(SAFE_Y_INSET, Grid.h - @h - SAFE_Y_INSET)
        @x = (@item.x + (@item.w / 2)).clamp(SAFE_X_INSET, Grid.w - @w - SAFE_X_INSET)
        @primitive_marker = :solid
        [self].concat(buttons)
      end

      def build_label(text, button)
        button.merge({
          text: text,
          size_px: 30,
          x: button.x + (button.w / 2),
          y: button.y + (button.h / 2),
          anchor_x: 0.5,
          anchor_y: 0.5,
          r: 255,
          b: 255,
          g: 255,
          a: 255,
          primitive_marker: :label
        })
      end

      def buttons
        gap = 8
        button_width = @w / 3 - gap
        button_height = 46
        use_button = {
          x: @x + gap,
          y: @y + gap,
          w: button_width,
          h: button_height,
          r: 255,
          g: 0,
          b: 0,
          a: 255,
          primitive_marker: :solid
        }
        use_button_label = build_label("Use", use_button)

        throw_button = use_button.merge({
          x: use_button.x + button_width + (gap / 2),
        })
        throw_button_label = build_label("Throw", throw_button)

        drop_button = use_button.merge({
          x: throw_button.x + button_width + (gap / 2),
        })
        drop_button_label = build_label("Drop", drop_button)

        @rendered_buttons.use = use_button
        @rendered_buttons.throw = throw_button
        @rendered_buttons.drop = drop_button
        [use_button, use_button_label, throw_button, throw_button_label, drop_button, drop_button_label]
      end
    end
  end
end
