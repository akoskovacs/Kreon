
module Krankorde
    module GraphVisitor
        refine AST::Number do
            def draw_graph(graph)
                return graph.add_nodes(@number.to_s)
            end
        end

        refine AST::Identifier do
            def draw_graph(graph)
                return graph.add_nodes(@identifier.to_s)
            end
        end

        refine AST::Binary do
            def draw_graph(graph)
                left = @left&.draw_graph(graph)
                right = @right&.draw_graph(graph)
                op = graph.add_nodes(@operator.to_s)
                graph.add_edges(op, left) unless left.nil?
                graph.add_edges(op, right) unless right.nil?
                return op
            end
        end

        refine AST::Unary do
            def draw_graph(graph)
                left = @left&.draw_graph(graph)
                op = graph.add_nodes(@operator.to_s)
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
                node = graph.add_nodes(class_name)
                @statements.each do |stmt|
                    new_node = stmt.draw_graph(graph)
                    graph.add_edges(node, new_node) unless node.nil?
                end
                return node
            end
        end
    end
end