# require "vendor/sprite_kit/sprite_kit/primitives.rb"

module App
  module Ui
    class Inventory < SpriteKit::Sprite
      NIL_ITEM = {
        w: 32, h: 32,
        source_x: 663,
        source_y: 119,
        source_h: 16,
        source_w: 16,
        path: "sprites/kenney_1-bit-pack/tilesheet/colored-transparent.png"
      }
      # BACKPACK = {
      #   path
      # }
      BACKPACK = {
        source_x: 799,
        source_y: 272,
        source_h: 16,
        source_w: 16,
        path: "sprites/kenney_1-bit-pack/tilesheet/colored-transparent.png"
      }

      attr_accessor :rendered_items, :items

      def initialize(items:, **kwargs)
        super(**kwargs)

        @items = items
        @rows = 5
        @columns = 5
        @rendered_items = []
      end

      def backpack_icon_bounding_box
        Layout.rect(
          row: Layout.row_count - 1,
          col: Layout.col_count - 2,
          w: 1,
          h: 1,
        )
      end

      def render_backpack_icon
        rect = backpack_icon_bounding_box
        padding = 2
        rect.x += padding
        rect.y -= padding
        rect.w -= padding
        rect.h -= padding

        borders = ::SpriteKit::Primitives.borders(rect, border_width: 2, padding: padding, color: {
          r: 200,
          g: 200,
          b: 200,
          a: 255
        }).values
        borders << rect.merge(BACKPACK)
        borders
      end

      def render_item_popup(item)

      end

      def inventory_bounding_box
        Layout.rect(
          row: Layout.row_count - 2 - @rows + 1,
          col: Layout.col_count - 2 - @columns + 1,
          w: @rows,
          h: @columns,
        )
      end

      def render_inventory
        box = inventory_bounding_box
        background = box.merge({
          r: 32,
          g: 32,
          b: 32,
          a: 255,
          path: :solid
        })
        [background].concat(render_items)
      end

      def render_items
        row = 0
        col = 0

        rect = inventory_bounding_box

        items = []
        @rendered_items = []
        @items.each do |item|
          rect = Layout.rect(
            row: Layout.row_count - 2 - row,
            col: Layout.col_count - 2 - col,
            w: 1,
            h: 1,
          )

          outline = NIL_ITEM.clone.tap do |i|
            i.x = rect.x
            i.y = rect.y
            i.w = rect.w
            i.h = rect.h
          end

          items << outline

          if item
            cloned_item = item.clone.tap do |i|
              i.x = rect.x + (rect.w / 3) / 2
              i.y = rect.y + (rect.h / 3) / 2
              i.w = (rect.w / 3) * 2
              i.h = (rect.h / 3) * 2
            end
            items << cloned_item
            @rendered_items << cloned_item
          end

          col += 1
          if col >= @columns
            row += 1
            col = 0
          end
        end
        items
      end
    end
  end
end
