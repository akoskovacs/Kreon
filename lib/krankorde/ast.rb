module Krankorde
    module AST
        class Node
            def class_name
                Rainbow(Helpers::FormatHelper.class_name(self.class)).color(:purple)
            end
        end

        class Statement < Node
            attr_accessor :statement

            def initialize(stmt = [])
              @statement = stmt
            end
        end

        class Statements < Statement
            attr_accessor :statements
            def initialize(stmts = [])
              @statements = stmts
            end
        end

        class If < Statements
            attr_accessor :token
            attr_accessor :condition
            attr_accessor :else_statements

            def initialize(tok, cond, stmts, else_stmts = nil)
                @token = tok
                @condition = cond
                @statements = stmts
                @else_statements = else_stmts
            end
        end

        class While < Statements
            attr_accessor :token
            attr_accessor :condition
            def initialize(tok, cond, stmts)
                @token = tok
                @condition = cond
                @statements = stmts
            end
        end

        class Assignment < Statement
            attr_accessor :assigned_to
            attr_accessor :expression
            attr_accessor :assignment

            def initialize(assign_token, assigned_to, expr)
                @assigned_to = assigned_to
                @expression = expr
                @assignment = assign_token
            end
        end

        class Expression < Node
        end

        class Unary < Expression
            attr_accessor :operator
            attr_accessor :right

            def initialize(operator, right)
                @operator = operator
                @right = right
            end
        end

        class Binary < Unary
            attr_accessor :left

            def initialize(operator, left, right)
                super(operator, right)
                @left = left
            end
        end

        # Node containing just one token
        class Leaf < Node
            attr_accessor :token
            def initialize(tok)
                @token = tok
            end

            def to_s
                return "(#{class_name} #{@token.to_s})"
            end
        end

        class Number < Leaf
        end

        class Identifier < Leaf
        end

        class Null < Leaf
        end

        class BoolConst < Leaf
        end
    end
end