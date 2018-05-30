module Krankorde
    class Token
        attr_accessor :type
        attr_accessor :value
        attr_accessor :index

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
            s = "[#{@type}"
            s += ", #{@value}" unless @value.nil?
            s += ", #{@index}" unless @index.nil?
            return s + "]"
        end
    end
end