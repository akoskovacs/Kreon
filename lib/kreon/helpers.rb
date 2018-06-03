
module Kreon
    module Helpers
        module FormatHelper
            extend self

            # Give level*2 number of spaces for formatting
            # @return [String]
            def level_spaces(level = 0)
                return " "*2*level
            end

            # Give only the class name
            # @return [String]
            def class_name(klass)
                return klass.name.split("::").last
            end
        end
    end
end