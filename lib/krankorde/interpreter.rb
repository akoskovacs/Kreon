module Krankorde
    class Interpreter
        attr_accessor :prompt

        def initialize(prompt = "> ")
            show_copyright
            @prompt = prompt
        end

        def show_copyright
            puts "Krankorde (C) Ákos Kovács - 2018"
            puts
        end

        def interpret
            loop do
                line = Readline::readline @prompt
                break if line == "quit" || line == "exit" || line == nil
                tokenizer = Tokenizer.new(line)
                parser = Parser.new(tokenizer)
                puts parser.parse
            end
            puts
            puts "Bye and have a nice day!"
        end
    end
end