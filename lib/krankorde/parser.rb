module Krankorde
    class Parser
        def initialize(tokenizer)
            @tokenizer = tokenizer
            @parse_errors = []
        end

        def parse
            @tokenizer.tokenize
            stmts = parse_statements
            puts @parse_errors
            return stmts
        end

        private 
            def show_error err
                clname = caller.first[/`(.*)'/, 1]
                str = "#{clname}: #{err}"
                @parse_errors << str
            end

            def parse_statements
                stmts = []
                loop do
                    stmt = parse_statement
                    break if stmt.nil?
                    stmts << stmt
                end
                return AST::Statements.new stmts
            end

            # <statement> ::= <expr> ';'
            #             |   ID '=' <expr> ';'
            def parse_statement
                tok = @tokenizer.token
                return nil if tok.nil?
                node = nil
                if tok.is_identifier?
                    node = parse_assignment
                else
                    node = parse_expression
                end
                unless @tokenizer.is_next_an? :semi_colon
                    show_error "Expected ';' at the end."
                end
                return AST::Statement.new(node)
            end

            def parse_assignment
                return nil
            end

            # <expr> ::= <term> { ('+' | '-') <term> }
            def parse_expression
                first = parse_term
                #puts "parse_expression", first
                return nil if first.nil?
                while @tokenizer.is_next_an_operator? '+', '-'
                    optok = @tokenizer.token
                    @tokenizer.get_next
                    second = parse_term
                    break if second.nil? 
                    first = AST::Binary.new(optok, first, second)
                end
                return first
            end

            # <term> ::= <factor> { ('*' | '/') <factor> }
            def parse_term
                first = parse_factor
                #puts "parse_term", first
                return nil if first.nil?
                while @tokenizer.is_next_an_operator? '*', '/'
                    optok = @tokenizer.token
                    @tokenizer.get_next
                    second = parse_factor
                    break if second.nil? 
                    first = AST::Binary.new(optok, first, second)
                end
                return first
            end

            # <factor> ::= ['+', '-'] <atom>
            #          |   '(' <expr> ')'
            def parse_factor
                tok = @tokenizer.token
                return nil if tok.nil?
                if tok.type == :operator && tok.value == '+' || tok.value == '-'
                    @tokenizer.get_next
                    return AST::Unary.new(tok, parse_atom)
                elsif tok.type == :number || tok.type == :identifier
                    return parse_atom
                else
                    show_error "Unknown token #{tok}!"
                end
            end

            def parse_atom
                tok = @tokenizer.token
                if tok.is_identifier?
                    return AST::Identifier.new(tok)
                elsif tok.is_number?
                    return AST::Number.new(tok)
                else
                    show_error "Unknown atom #{tok}!"
                end
                return nil
            end
    end
end