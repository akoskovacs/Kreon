module Krankorde
    class Interpreter
        attr_accessor :prompt

        def initialize(prompt = "> ")
            show_copyright
            @prompt = prompt
            @variable = {}
        end

        def show_copyright
            puts "Krankorde (C) Ákos Kovács - 2018"
            puts
        end

        def eval_statements root
            last = nil
            root.statements.each do |stmt|
                last = eval_statement(stmt)
            end
            return last
        end

        def eval_statement root
            return eval_ast(root.statement)
        end

        def eval_if_statement root
            cond = eval_ast(root.condition)
            if cond != 0
                puts "true: #{root.statements}"
                return eval_ast(root.statements)
            else
                unless root.else_statements.nil?
                    return eval_ast(root.else_statements)
                end
            end
            return 0
        end

        def eval_while_statement root
            expr = 0
            while eval_ast(root.condition) != 0
                expr = eval_ast(root.statements)
            end
            return expr
        end

        def eval_binary root
            left = eval_ast(root.left)
            right = eval_ast(root.right)
            if left.nil? || right.nil?
                puts "No value for one of the subexpressions!"
                return 0
            end
            val = (case root.operator.value
            when "+" then left + right
            when "-" then left - right
            when "*" then left * right
            when "/" then left / right
            when "||" then (left!=0 || right!=0) ? 1 : 0
            when "&&" then (left!=0 && right!=0) ? 1 : 0
            when "<" then (left < right) ? 1 : 0
            when ">" then (left > right) ? 1 : 0
            when "<=" then (left <= right) ? 1 : 0
            when ">=" then (left >= right) ? 1 : 0
            when "==" then (left == right) ? 1 : 0
            when "!=" then (left != right) ? 1 : 0
            else
                puts "No binary operator '#{root.operator}'!"
                0;
            end)
            return val
        end

        def eval_unary root
            right = eval_ast(root.right)
            if root.operator.is_operator? '-'
                return -right
            elsif root.operator.is_operator? '!'
                return right == 0 ? 1 : 0;
            end
            return right
        end

        def eval_assignment root
            id = root.assigned_to.token.value
            expr = eval_ast(root.expression)
            @variable[id] = expr
            return expr
        end

        def eval_ast(root)
            return nil if root == nil
            #puts root.inspect
            if root.instance_of?(AST::Number)
                return root.token.value
            elsif root.instance_of?(AST::Identifier)
                id = root.token.value
                unless @variable.include? id
                    puts "Variable '#{id}' is not defined!"
                end
                return @variable[id]
            elsif root.instance_of?(AST::If)
                puts "is an if"
                return eval_if_statement(root)
            elsif root.instance_of?(AST::While)
                return eval_while_statement(root)
            elsif root.instance_of?(AST::Unary)
                return eval_unary(root)
            elsif root.instance_of?(AST::Binary)
                return eval_binary(root)
            elsif root.instance_of?(AST::Assignment)
                return eval_assignment(root)
            elsif root.instance_of?(AST::BoolConst)
                return root.token.type == :false ? 0 : 1
            elsif root.instance_of?(AST::Null)
                return 0
            else
                puts "#{root.class} is not implemented yet for evaluation"
                return 0
            end
        end

        using AST::PrettyPrintVisitor
        def interpret
            loop do
                line = Readline::readline @prompt
                break if line == "quit" || line == "exit" || line == nil
                tokenizer = Tokenizer.new(line)
                puts tokenizer.tokenize
                parser = Parser.new(tokenizer)
                ast = parser.parse
                puts ast.to_pretty_ast
                #puts ast.to_pretty_syntax
                ast_ev = eval_statements(ast) || "<nil>"
                puts " => #{ast_ev}"
                draw_graph('/tmp/ast.png', ast)
            end
            puts
            puts "Bye and have a nice day!"
        end

        using GraphVisitor
        def draw_graph file_name, ast
            gviz = GraphViz.new(:G, type: :digraph)
            Rainbow.enabled = false
            ast.draw_graph(gviz)
            Rainbow.enabled = true
            gviz.output(png: file_name)
        end
    end
end