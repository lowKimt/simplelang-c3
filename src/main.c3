module simplelang;
import std::io;
import parser;
import lexer;
import interpreter;

fn void repl() 
{
    Lexer lex = lexer::new_lexer("");
    Parser parser = parser::new_parser(&lex);
    Interpreter interp = interpreter::new_interpreter();
    defer interp.free(mem);
	while (1) @pool()
    {
        io::print("simplelang> ");
        io::stdout().flush()!!;
        if (try input = io::treadline())
        {
            lex.new_input(input);
            parser.reset();
            ProgramNode*? pn = parser.program();
            if (catch perr = pn) {
                io::eprintfn("Parser error: %s", perr);
                continue;
            }

            defer pn.free(mem);

            if (catch err = interp.visit_program(pn)) {
                io::eprintfn("Interpreter error: %s", err);
                continue;
            }
        }
    };	
}

fn int main(String[] args)
{
	repl();
	return 0;
}
