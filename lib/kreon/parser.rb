module Kreon
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

            # <stmts> ::= <stmt> | <stmt> <stmts>
            def parse_statements
                stmts = []
                loop do
                    stmt = parse_statement
                    break if stmt.nil?
                    stmts << stmt
                end
                return AST::Statements.new(stmts)
            end

            # <stmt> ::= <expr> ';'
            #        |   ID '=' <expr> ';'
            #        |   <if_stmt>
            #        |   <while_stmt>
            def parse_statement
                tok = @tokenizer.token
                #puts "stmt: #{tok}"
                if tok == nil || tok.is_type?(:semi_colon) || tok.is_type?(:rbrace)
                    return nil
                elsif tok.is_type? :if
                    return parse_if_statement
                elsif tok.is_type? :while
                    return parse_while_statement
                else
                    node = tok.is_identifier? ? parse_assignment : parse_expression
                end
                return nil if node == nil
                if @tokenizer.is_next_an? :semi_colon
                    @tokenizer.get_next
                    return AST::Statement.new(node)
                else
                    return show_error "Expected ';' at the end."
                end
            end

            # <block> ::= '{' <stmts> '}'
            def parse_block
                tok = @tokenizer.token
                unless tok.is_type? :lbrace
                    return show_error "Expected '{' for the block statement!"
                end
                @tokenizer.get_next
                #puts "block: #{@tokenizer.token.inspect}"
                stmts = parse_statements
                #puts "block_brace: #{@tokenizer.token}"
                unless @tokenizer.is_current_an? :rbrace
                    return show_error "Expected '}' for the block statement!"
                end
                return stmts
            end

            # <if_stmt> ::= 'if' <expr> <block> [ 'else' <block> ]
            def parse_if_statement
                if_tok = @tokenizer.token
                unless if_tok.is_type? :if
                    return show_error "Expected if keyword!"
                end
                @tokenizer.get_next
                cond = parse_expression
                @tokenizer.get_next
                stmts = parse_block
                if @tokenizer.is_next_an? :else
                    @tokenizer.get_next
                    estmts = parse_block
                    return AST::If.new(if_tok, cond, stmts, estmts)
                else
                    return AST::If.new(if_tok, cond, stmts)
                end
            end

            # <while_stmt> ::= 'while' <expr> <block>
            def parse_while_statement
                while_tok = @tokenizer.token
                unless while_tok.is_type? :while
                    return show_error "Expected while keyword!"
                end
                @tokenizer.get_next
                #puts "while: #{@tokenizer.token}"
                cond = parse_expression
                @tokenizer.get_next
                stmts = parse_block
                return AST::While.new(while_tok, cond, stmts)
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
                return parse_binary_operator('&&') { parse_relational }
            end

            # <rel> ::= <rel_eq> { ( '<', '>', '<=', '>=' ) <rel_eq> }
            def parse_relational
                return parse_binary_operator('<', '>', '<=', '>=') {
                    parse_relational_eq
                }
            end

            # <rel_eq> ::= <add_expr> { ( '==', '!=' ) <add_expr> }
            def parse_relational_eq
                return parse_binary_operator('==', '!=') { parse_addition_expression }
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
                if @tokenizer.is_current_an_operator? '+', '-', '!'
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