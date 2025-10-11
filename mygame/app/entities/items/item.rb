require "app/entities/entity.rb"

module App
  module Entities
    module Items
      class Item < Entity
        attr_accessor :name

        def initialize(...)
          super(...)
          @item = true
          @collideable = false
        end

        def dead?
          false
        end
      end
    end
  end
end
