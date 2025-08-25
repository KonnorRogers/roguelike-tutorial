module App
  module Entities
    module Mixins
      module Fighter
        def initialize(**kwargs)
          super(**kwargs)

          puts "@health: ", instance_variable_get("@health")
          required_variables = [
            "@health",
            "@max_health",
            "@defense",
            "@power"
          ]

          unset_properties = []
          required_variables.each do |var|
            if instance_variable_get(var).nil?
              unset_properties << var
            end
          end

          if unset_properties.length > 0
            raise StandardError.new("#{unset_properties.join(", ")} ivars not set for #{self}")
          end
        end

        def health
          @health
        end

        def health=(val)
          @health = val.clamp(0, @max_health)
        end
      end
    end
  end
end
