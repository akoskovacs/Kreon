
module Krankorde
    module Helpers
        module FormatHelper
            extend self

            def class_name(klass)
                return klass.name.split("::").last
            end
        end
    end
end