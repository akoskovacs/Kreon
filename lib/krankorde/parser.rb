module Krankorde
    attr_reader :parse_errors

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
                return nil
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
                return nil if (tok.nil? || tok == :semi_colon)
                node = tok.is_identifier? ? parse_assignment : parse_expression
                return nil if node == nil
                if @tokenizer.is_next_an? :semi_colon
                    @tokenizer.get_next
                    return AST::Statement.new(node)
                else
                    return show_error "Expected ';' at the end."
                end
            end

            def parse_assignment
                ftok = @tokenizer.token
                stok = @tokenizer.peek_next
                #puts ftok, stok
                if ftok.is_type?(:identifier) && stok&.is_type?(:assign)
                    atom = parse_atom
                    #puts atom
                    stok = @tokenizer.get_next
                    unless stok.is_type?(:assign)
                        return show_error "Expected '=' for assignment!"
                    end
                    @tokenizer.get_next
                    expr = parse_expression
                    if expr != nil
                        return AST::Assignment.new(stok, atom, expr)
                    else
                        show_error "Expected expression after '=' for assignment!"
                        return atom
                    end
                end
                return parse_expression
            end

            def parse_binary_operator(*oprs, &next_parser)
                first = next_parser.call()
                return nil if first.nil?
                #@tokenizer.get_prev
                while @tokenizer.is_next_an_operator? *oprs
                    optok = @tokenizer.token
                    #puts "expr, optok: #{optok}"
                    @tokenizer.get_next
                    second = next_parser.call()
                    break if second.nil? 
                    first = AST::Binary.new(optok, first, second)
                end
                return first
            end

            def parse_expression
                return parse_or_expression
            end

            # <or_expr> ::= <and_term> { '||' <and_expr> }
            def parse_or_expression
                return parse_binary_operator('||') { parse_and_expression }
            end

            # <and_expr> ::= <add_expr> { '||' <add_expr> }
            def parse_and_expression
                return parse_binary_operator('&&') { parse_addition_expression }
            end

            # <add_expr> ::= <term> { ('+' | '-') <term> }
            def parse_addition_expression
                return parse_binary_operator('+', '-') { parse_term }
            end

            # <term> ::= <factor> { ('*' | '/') <factor> }
            def parse_term
                return parse_binary_operator('*', '/') { parse_factor }
            end

            # <factor> ::= ['+', '-'] <atom>
            #          |   '(' <expr> ')'
            def parse_factor
                tok = @tokenizer.token
                return nil if tok.nil?
                if tok.type == :operator && tok.value == '+' || tok.value == '-'
                    @tokenizer.get_next
                    return AST::Unary.new(tok, parse_factor)
                elsif tok.type == :lparen
                    @tokenizer.get_next
                    expr = parse_expression
                    show_error "Unmatched closing ')'!" unless @tokenizer.is_next_an? :rparen
                    return expr
                elsif tok.is_atom?
                    return parse_atom
                elsif tok == nil || tok.type == :semi_colon
                    return nil
                else
                    show_error "Unknown token #{tok}!"
                end
            end

            # <atom> ::= ID | NUM
            def parse_atom
                tok = @tokenizer.token
                if tok.is_identifier?
                    return AST::Identifier.new(tok)
                elsif tok.is_number?
                    return AST::Number.new(tok)
                elsif tok.is_number?
                    return AST::Number.new(tok)
                elsif tok.is_boolean?
                    return AST::BoolConst.new(tok)
                elsif tok.is_null?
                    return AST::Null.new(tok)
                elsif tok.nil?
                    return nil
                else
                    show_error "Unknown atom #{tok}!"
                end
            end
    end
end