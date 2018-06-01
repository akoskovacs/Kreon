module Krankorde
    module AST
        # Pretty-prints the AST to the console
        module PrettyPrintVisitor
            refine AST::Number do
                def to_pretty_ast(_level = 0)
                    return "(#{class_name} #{@number.to_s})"                
                end

                def to_pretty_syntax(_level = 0)
                    return @number.to_pretty_value
                end
            end

            refine AST::Identifier do
                def to_pretty_ast(_level = 0)
                    return "(#{class_name} #{@identifier.to_s})"                
                end

                def to_pretty_syntax(_level = 0)
                    return @identifier.to_pretty_value
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

                def to_pretty_syntax(level = 0)
                    return @left.to_pretty_syntax(level) +
                           " #{operator.to_pretty_value} " +
                           @right.to_pretty_syntax(level)
                end
            end

            refine AST::Unary do
                def to_pretty_ast(level = 0)
                    return "(#{class_name} #{@operator} #{@right.to_pretty_ast(level+1)})"
                end

                # Pretty prints for 'variable = <expr>'
                def to_pretty_syntax(level = 0)
                    return "#{@operator.to_pretty_syntax(level)}#{@right.to_pretty_syntax(level)}"
                end
            end

            refine AST::Assignment do
                def to_pretty_ast(level = 0)
                    next_level = level + 1
                    prefix = "\n#{Helpers::FormatHelper.level_spaces(next_level)}"
                    expr = @expression.to_pretty_ast(next_level+1)
                    return "(#{class_name} #{@assigned_to.to_pretty_ast(next_level)}#{prefix}#{expr})"
                end

                def to_pretty_syntax(level = 0)
                    return "#{@assigned_to.to_pretty_syntax(level)} = " + 
                           "#{@expression.to_pretty_syntax(level)}"
                end
            end

            refine AST::Statement do
                def to_pretty_ast(level = 0)
                    prefix = "\n#{Helpers::FormatHelper.level_spaces(level+1)}"
                    return "(#{class_name}#{prefix}#{@statement.to_pretty_ast(level + 1)})"
                end

                def to_pretty_syntax(level = 0)
                    return "#{@statement.to_pretty_syntax(level)};\n"
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

                def to_pretty_syntax(level = 0)
                    prefix = "\n#{Helpers::FormatHelper.level_spaces(level+1)}"

                    stmts = @statements.map do |st|
                        st.to_pretty_syntax(level+1)
                    end.join(prefix)
                    return stmts
                end
            end
        end
    end
end