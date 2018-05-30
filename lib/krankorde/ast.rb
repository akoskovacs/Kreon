module Krankorde
    module AST
        class Node
            def class_name
                self.class.name.split("::").last
            end

            def to_s
               return "()" 
            end
        end

        class Statement < Node
            attr_accessor :statement

            def initialize(stmt = [])
              @statement = stmt
            end

            def to_s
                return "(#{class_name} #{@statement})"
            end
        end

        class Statements < Statement
            attr_accessor :statements
            def initialize(stmts = [])
              @statements = stmts
            end

            def to_s
                return "(#{class_name} #{@statements.map(&:to_s).join ','})"
            end
        end

        class Assignment < Statement
            attr_accessor :assignee
            attr_accessor :expression

            def initialize(assigned_to, expr)
                @assignee = assigned_to
                @expression = expr
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

            def to_s
                return "(#{class_name} #{@operator} #{@right})"
            end
        end

        class Binary < Unary
            attr_accessor :left

            def initialize(operator, left, right)
                super(operator, right)
                @left = left
            end

            def to_s
                return "(#{class_name} #{@operator} #{@left} #{@right})"
            end
        end

        class Number < Node
            attr_accessor :number

            def initialize(num)
                @number = num
            end

            def to_s
                return "(#{class_name} #{@number})"                
            end
        end

        class Identifier < Node
            attr_accessor :identifier

            def initialize(ident)
                @identifier = ident
            end

            def to_s
                return "(#{class_name} #{@identifier})"                
            end
        end
    end
end