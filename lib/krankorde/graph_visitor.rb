
module Krankorde
    module GraphVisitor
        refine AST::Leaf do
            def draw_graph(graph)
                return graph.add_nodes(@token.to_s)
            end
        end

        refine AST::Binary do
            def draw_graph(graph)
                left = @left&.draw_graph(graph)
                right = @right&.draw_graph(graph)
                op = graph.add_nodes("(#{class_name} #{@operator.to_s})")
                graph.add_edges(op, left) unless left.nil?
                graph.add_edges(op, right) unless right.nil?
                return op
            end
        end

        refine AST::Unary do
            def draw_graph(graph)
                left = @left&.draw_graph(graph)
                op = graph.add_nodes("(#{class_name} #{@operator.to_s})")
                graph.add_edges(op, left) unless left.nil?
                return op
            end
        end

        refine AST::Assignment do
            def draw_graph(graph)
                left = @assigned_to&.draw_graph(graph)
                right = @expression&.draw_graph(graph)
                assign = graph.add_nodes(@assignment.to_s)
                graph.add_edges(assign, left) unless left.nil?
                graph.add_edges(assign, right) unless right.nil?
                return assign
            end
        end

        refine AST::Statement do
            def draw_graph(graph)
                return @statement&.draw_graph(graph)
            end
        end

        refine AST::Statements do
            def draw_graph(graph)
                node = graph.add_nodes("(#{class_name} #{hash.to_s[-5..-1]})")
                @statements.each do |stmt|
                    new_node = stmt.draw_graph(graph)
                    graph.add_edges(node, new_node) unless node.nil?
                end
                return node
            end
        end

        refine AST::If do
            def draw_graph(graph)
                cond = @condition&.draw_graph(graph)
                ifst = @statements&.draw_graph(graph)
                elsest = @else_statements&.draw_graph(graph)
                stmt = graph.add_nodes("(#{class_name} #{@token.to_s})")
                graph.add_edges(stmt, cond) unless cond.nil?
                graph.add_edges(stmt, ifst) unless ifst.nil?
                graph.add_edges(stmt, elsest) unless elsest.nil?
                return stmt
            end
        end

        refine AST::While do
            def draw_graph(graph)
                cond = @condition&.draw_graph(graph)
                stmts = @statements&.draw_graph(graph)
                stmt = graph.add_nodes("(#{class_name} #{@token.to_s})")
                graph.add_edges(stmt, cond) unless cond.nil?
                graph.add_edges(stmt, stmts) unless stmts.nil?
                return stmt
            end
        end

    end
end