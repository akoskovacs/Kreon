module Krankorde
    class Token
        attr_accessor :type
        attr_accessor :value
        attr_accessor :index
        VALUE_COLORS = {
            string: :green,
            identifier: :navyblue,
            number: :yellow,
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
            return @type == :number
        end

        def is_identifier?
            return @type == :identifier
        end

        def is_string?
            return @type == :string
        end

        def to_s
            color = VALUE_COLORS[@type] || :azure
            s = "[#{Rainbow(@type).color(:maroon)}"
            s += ", #{Rainbow(@value).color(color)}" unless @value.nil?
            s += ", #{Rainbow(@index).color(:darkblue)}" unless @index.nil?
            return s + "]"
        end
    end
end