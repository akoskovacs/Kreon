module Krankorde
    module AST
        # Pretty-prints the AST to the console
        module PrettyPrintVisitor
            refine AST::Number do
                def to_pretty_ast(_level = 0)
                    return "(#{class_name} #{@number.to_s})"                
                end
            end

            refine AST::Identifier do
                def to_pretty_ast(_level = 0)
                    return "(#{class_name} #{@identifier.to_s})"                
                end
            end

            refine AST::Binary do
                def to_pretty_ast(level = 0)
                    nlevel = level + 1
                    prefix = "\n#{Helpers::FormatHelper.level_spaces(nlevel)}"
                    return "(#{class_name} #{@operator}" +
                        "#{prefix}#{@left.to_pretty_ast(nlevel)}" +
                        "#{prefix}#{@right.to_pretty_ast(nlevel)})"
                end
            end

            refine AST::Unary do
                def to_pretty_ast(level = 0)
                    return "(#{class_name} #{@operator} #{@right.to_pretty_ast(level+1)})"
                end
            end

            refine AST::Assignment do
                def to_pretty_ast(level = 0)
                    next_level = level + 1
                    prefix = "\n#{Helpers::FormatHelper.level_spaces(next_level)}"
                    expr = @expression.to_pretty_ast(next_level+1)
                    return "(#{class_name} #{@assigned_to.to_pretty_ast(next_level)}#{prefix}#{expr})"
                end
            end

            refine AST::Statement do
                def to_pretty_ast(level = 0)
                    prefix = "\n#{Helpers::FormatHelper.level_spaces(level+1)}"
                    return "(#{class_name}#{prefix}#{@statement.to_pretty_ast(level + 1)})"
                end
            end

            refine AST::Statements do
                def to_pretty_ast(level = 0)
                    prefix = "\n#{Helpers::FormatHelper.level_spaces(level+1)}"
                    stmts = @statements.map do |st|
                        st.to_pretty_ast(level+1)
                    end.join(prefix)

                    return "(#{class_name}#{prefix}#{stmts})"
                end
            end
        end
    end
end