module Kreon
    class Tokenizer
        PATTERNS = {
            true: /(\btrue\b)/,
            false: /(\bfalse\b)/,
            null: /(\bnull\b)/,
            if: /(\bif\b)/,
            else: /(\belse\b)/,
            while: /(\bwhile\b)/,
            number: /(\d+)/,
            identifier: /(\w[\d\w]*)/,
            operator: /(\|\||\&\&|>=|<=|==|!=|>|<|[\+\-\*\/!])/,
            string: /("[^"]*")/,
            assign: /(=)/,
            semi_colon: /(;)/,
            comma: /(,)/,
            lparen: /(\()/,
            rparen: /(\))/,
            lbrace: /(\{)/,
            rbrace: /(\})/
        }
        
        attr_reader :tokens

        def initialize(source, source_name = nil)
            @source = source
            @line = 0
            @index = 0
            @scan = nil
            @tokens = []
            @source_name = source_name
        end

        def tokenize
           return [] if @source.nil?
           # Order matters
           token_id = PATTERNS.keys
           #puts token_id.inspect
           # Create a oneline regex with all sub-regexes in alternation
           regex = Regexp.new(token_id.map do |name|
            PATTERNS[name].source
           end.join('|'))

           @scan = @source.scan regex
           #puts @scan.inspect
           cindex = 0
           @scan.each do |scan_elem|
                scan_elem.each_with_index do |match, ind|
                    next if match.nil?
                    tokid = token_id[ind]
                    value = nil
                    case tokid
                    when :number then
                        value = match.to_i
                    when :identifier, :operator, :string then
                        value = match
                    end
                    tok = Token.new(token_id[ind], value, cindex)
                    cindex += match.length
                    @tokens << tok
                end
            end
            # Make it end eventually...
            @tokens << nil
            return @tokens
        end

        # @return [Symbol]
        def peek_next
            return @tokens.at(@index + 1)
        end

        # @return [Symbol]
        def peek_prev
            return nil if @index <= 0
            return @tokens.at(@index - 1)
        end

        # @return [Symbol]
        def get_next
            tok = peek_next
            @index += 1
            return tok
        end

        # @return [Symbol]
        def get_prev
           tok = peek_prev 
           @index -= 1
           return tok
        end

        # @return [[Symbol]]
        def token
            return @tokens.at(@index)
        end

        # @return [Bool]
        def is_next_an? expected_type
            get_next # must make it current
            return true if is_current_an? expected_type
            get_prev # revert
            return false
        end

        alias is_next_a? is_next_an?

        # @return [Bool]
        def is_next_an_operator? *oprs
            if is_next_an?(:operator) 
                return true if token.is_operator?(*oprs)
                get_prev
            end
            return false
        end

        # @return [Bool]
        def is_current_an? expected_type
            return token != nil && token.type == expected_type
        end

        # @return [Bool]
        def is_current_an_operator? *oprs
            return token != nil && token.is_operator?(*oprs)
        end
    end

end