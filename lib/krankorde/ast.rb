module Krankorde
    module AST
        class Node
            def class_name
                Rainbow(self.class.name.split("::").last).color(:purple)
            end

            def to_tree_s(level)
               return tree_level(level) + "()" 
            end

            def to_s
                to_tree_s(0)
            end

            protected 
                def tree_level(level = 0)
                    return " "*2*level
                end
        end

        class Statement < Node
            attr_accessor :statement

            def initialize(stmt = [])
              @statement = stmt
            end

            def to_tree_s(level)
               return "(#{class_name}\n#{tree_level(level+1)}#{@statement})"
            end
        end

        class Statements < Statement
            attr_accessor :statements
            def initialize(stmts = [])
              @statements = stmts
            end

            def to_tree_s(level)
                lev = "\n" + tree_level(level + 1)
                stmts = @statements.map do |st|
                    st.to_tree_s(level+1)
                end.join(lev)

                return "(#{class_name}#{lev}#{stmts})"
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

            def to_tree_s(level)
                return "(#{class_name} #{@operator} #{@right.to_tree_s(level+1)})"
            end
        end

        class Binary < Unary
            attr_accessor :left

            def initialize(operator, left, right)
                super(operator, right)
                @left = left
            end

            def to_tree_s(level)
                nlevel = level + 1
                lev = "\n" + tree_level(nlevel+2)
                return "(#{class_name} #{@operator}" +
                       "#{lev}#{@left.to_tree_s(nlevel+1)}" +
                       "#{lev}#{@right.to_tree_s(nlevel+1)})"
            end
        end

        class Number < Node
            attr_accessor :number

            def initialize(num)
                @number = num
            end

            def to_tree_s(level)
                #spaces = tree_level(level+1)
                return "(#{class_name} #{@number})"                
            end
        end

        class Identifier < Node
            attr_accessor :identifier

            def initialize(ident)
                @identifier = ident
            end

            def to_tree_s(level)
                spaces = tree_level(level+1)
                return "#{spaces}(#{class_name} #{@identifier})"                
            end
        end
    end
end