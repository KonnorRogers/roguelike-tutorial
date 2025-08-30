module App
  module Ui
    class HealthBar < SpriteKit::Sprite
      attr_accessor :entity, :health_color

      def initialize(entity:, **kwargs)
        super(**kwargs)

        @entity = entity

        @health_color = {
          b: 0,
          g: 0,
          r: 190,
          a: 255
        }
      end

      def health_text
        "#{entity.health} / #{entity.max_health} (#{health_percentage}%)"
      end

      def health_percentage
        ((entity.health / entity.max_health) * 100).round
      end

      def outline
        {
          w: @w,
          h: @h,
          x: @x,
          y: @y,
          r: 255,
          b: 255,
          g: 255,
          a: 255,
          primitive_marker: :sprite
        }
      end

      def fill

        outline_solid = outline
        w = (outline_solid.w * (health_percentage / 100)).round

        return nil if w <= 0

        padding = 2
        outline_solid.merge({
          x: outline_solid.x + padding,
          y: outline_solid.y + padding,
          w: w - (padding * 2),
          h: outline_solid.h - (padding * 2),
          **@health_color
        })
      end

      def track
        outline_solid = outline
        padding = 2
        outline_solid.merge({
          x: outline_solid.x + padding,
          y: outline_solid.y + padding,
          w: (outline_solid.w) - (padding * 2),
          h: outline_solid.h - (padding * 2),
          b: 0,
          g: 0,
          r: 0
        })
      end

      def label
        {
          x: @x + @w / 2,
          y: @y + @h / 2,
          w: @w,
          h: @h,
          anchor_x: 0.5,
          anchor_y: 0.5,
          text: health_text,
          primitive_marker: :label,
          r: 255,
          b: 255,
          g: 255,
          a: 255
        }
      end

      def prefab
        [
          outline,
          track,
          fill,
          label
        ]
      end
    end
  end
end
