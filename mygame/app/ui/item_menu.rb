
module App
  module Ui
    class ItemMenu < SpriteKit::Sprite
      attr_accessor :open, :item, :rendered_buttons, :item_index, :view

      SAFE_X_INSET = 50
      SAFE_Y_INSET = 50

      def initialize(open: false, item: nil, w: 300, h: 300, **kwargs)
        @open = open
        @item = item
        @item_index = nil
        # :inventory or :confirm
        @view = :inventory
        @rendered_buttons = {
          drop: nil,
          use: nil,
          throw: nil,
          confirm: nil,
          cancel: nil,
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
        @path = :solid
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
        buttons = {}
        if @view == :confirm
          buttons = {
            confirm: "Confirm",
            cancel: "Cancel"
          }
        else
          buttons = {
            use: "Use",
            throw: "Throw",
            drop: "Drop"
          }
        end

        keys = buttons.keys
        button_width = (@w / keys.length) - gap
        button_height = 46

        @rendered_buttons = {}
        rendered_items = []
        keys.each_with_index do |key, index|
          text = buttons[key]
          button = {
            id: key,
            x: @x + gap + ((gap * index) / 2) + (button_width * index),
            y: @y,
            w: button_width,
            h: button_height,
            r: 255,
            g: 0,
            b: 0,
            a: 255,
            path: :solid
          }
          rendered_items.push(button, build_label(text, button))
          @rendered_buttons[key] = button
        end

        rendered_items
      end
    end
  end
end
