module Krankorde
    class Tokenizer
        SCAN_REGEX = /(\d+)|(\w[\d\w]+)|([\+\-\*\/]|>|<|>=|<=|==)|("[^"]*")|(=)|(;)|(,)|(\()|(\))|(\{)|(\})/
        TOKEN_ID = [:number, :identifier, :operator, :string, :assign, :semi_colon, :comma, 
                    :lparen, :rparen, :lbrace, :rbrace]

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

           @scan = @source.scan SCAN_REGEX
           #puts @scan.inspect
           cindex = 0
           @scan.each do |scan_elem|
                scan_elem.each_with_index do |match, ind|
                    next if match.nil?
                    tokid = TOKEN_ID[ind]
                    value = nil
                    case tokid
                    when :number then
                        value = match.to_i
                    when :identifier, :operator, :string then
                        value = match
                    end
                    tok = Token.new(TOKEN_ID[ind], value, cindex)
                    cindex += match.length
                    @tokens << tok
                end
            end
           return @tokens
        end

        def peek_next
            return nil if (@index + 1) >= @tokens.length
            return @tokens[@index + 1]
        end

        def peek_prev
            return nil if (@index - 1) < 0 
            return @tokens[@index - 1] 
        end

        def get_next
            tok = peek_next
            @index += 1
            return tok
        end

        def get_prev
           tok = peek_prev 
           @index -= 1
           return tok
        end

        def token
            tok = @tokens[@index]
            #puts "tok: #{tok}, index: #{@index}"
            return tok
        end

        def is_next_an? expected_type
            tok = get_next
            if tok != nil && tok.type == expected_type
                get_next
                return true
            end
            get_prev
            return false
        end

        def is_next_an_operator? *oprs
            return is_next_an?(:operator) && token.is_operator?(oprs)
        end

        def is_current_an? expected_type
            tok = token
            return tok != nil && tok.type == expected_type
        end
    end

end