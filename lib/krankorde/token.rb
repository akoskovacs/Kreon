module Krankorde
    class Token
        attr_accessor :type
        attr_accessor :value
        attr_accessor :index
        VALUE_COLORS = {
            string: :green,
            identifier: :navyblue,
            number: :yellow,
            null: :darkgray,
            true: :yellow,
            false: :yellow,
            operator: :cyan
        }

        def initialize(type = :none, value = nil, index = nil)
            @type = type
            @value = value
            @index = index
        end

        def is_operator? *op
            is_op = @type == :operator

            return is_op if (op.nil? || op == [])
            return is_op && op.include?(@value)
        end

        def is_type? type
            return @type == type
        end

        def is_number?
            return is_type?(:number)
        end

        def is_identifier?
            return is_type?(:identifier)
        end

        def is_string?
            return is_type?(:string)
        end

        def is_boolean?
            return is_true? || is_false?
        end

        def is_true?
            return is_type?(:true)
        end

        def is_false?
            return is_type?(:false)
        end

        def is_null?
            return is_type?(:null)
        end

        def is_atom?
            return is_number? || is_identifier? || is_boolean? || is_null?
        end

        def to_pretty_value
            color = VALUE_COLORS[@type] || :azure
            str = ""
            str = Rainbow(@value).color(color) unless @value.nil?
            return str
        end

        def to_s
            s = "[#{Rainbow(@type).color(:maroon)}"
            s += ", #{to_pretty_value}" unless @value.nil?
            s += ", #{Rainbow(@index).color(:darkblue)}" unless @index.nil?
            return s + "]"
        end
    end
end