require "app/entities/entity.rb"

module App
  module Entities
    module Items
      class Item < Entity
        def initialize(...)
          super(...)
          @item = true
        end
      end
    end
  end
end
