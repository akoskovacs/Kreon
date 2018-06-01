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

            def to_tree_s(level)
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

        class Number < Node
            attr_accessor :number

            def initialize(num)
                @number = num
            end
        end

        class Identifier < Node
            attr_accessor :identifier

            def initialize(ident)
                @identifier = ident
            end
        end
    end
end