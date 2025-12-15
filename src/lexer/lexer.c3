module lexer;
import std::core::string;
import std::core::mem::allocator;
import std::io;

struct Lexer {
    String input;
    int pos;
    int line;
    int column;
    char current_char;
}

fn Lexer new_lexer(String input) 
{
    Lexer l;
    l.input = input;
    l.pos = 0;
    l.line = 1;
    l.column = 1;
    l.current_char = l.input[l.pos];
    return l;
}

fn void Lexer.new_input(Lexer *self, String input)
{
    self.input = input;
    self.pos = 0;
    self.line = 1;
    self.column = 1;
    self.current_char = self.input[self.pos];
}

fn void Lexer.advance(Lexer *self) 
{
    self.pos++;
    self.column++;
    if (self.pos >= self.input.len) {
        self.current_char = 0;
    } else {
        self.current_char = self.input[self.pos];
    }
}

fn String Lexer.integer(Lexer *self) 
{
    DString result;
    while (self.current_char >= '0' && self.current_char <= '9') {
        result.append_char(self.current_char);
        self.advance();
    }
    return result.tcopy_str();
}

// Note: We will advance past the starting & closing quotes here
fn String Lexer.string(Lexer *self)
{
    DString result;
    self.advance(); // Advance past the opening quote
    while (self.current_char != '"') {
        result.append_char(self.current_char);
        self.advance();
    }
    self.advance(); // Advance past the closing quote
    return result.tcopy_str();
}

fn String Lexer.identifier(Lexer *self) 
{
    DString result;
    while (
        (self.current_char >= '0' && self.current_char <= '9') ||
        (self.current_char >= 'a' && self.current_char <= 'z') ||
        (self.current_char >= 'A' && self.current_char <= 'Z') ||
        (self.current_char == '_')
        ) {
        result.append_char(self.current_char);
        self.advance();
    }
    return result.tcopy_str();
}

fn Token Lexer.next_token(Lexer *self)
{
    while (self.current_char != 0 && self.pos < self.input.len) {
        // Skip whitespace (but not newlines)
        if (self.current_char == ' ' || self.current_char == '\t' || self.current_char == '\r') {
            self.advance();
            continue;
        }

        // Handle newlines
        if (self.current_char == '\n') {
            self.line++;
            self.column = 0;  // Will become 1 after advance()
            self.advance();
            continue;
        }

        // Capture starting position BEFORE we consume any characters
        int start_line = self.line;
        int start_col = self.column;

        // Now tokenize
        if (self.current_char >= '0' && self.current_char <= '9') {
            return { INT, self.integer(), start_line, start_col };
        }

        if (
            (self.current_char >= '0' && self.current_char <= '9') ||
            (self.current_char >= 'A' && self.current_char <= 'Z') ||
            (self.current_char >= 'a' && self.current_char <= 'z') ||
            (self.current_char == '_')
            ){

            String id = self.identifier();

            // Keyword checks
            switch (id) {
                case "let":
                    return { LET, id, start_line, start_col };
                case "print":
                    return { PRINT, id, start_line, start_col };
                default:
                    return { IDENTIFIER, id, start_line, start_col };
            }
        }

        switch (self.current_char) {
        case '(':
            self.advance();
            return { LPAREN, "(", start_line, start_col };
        case ')':
            self.advance();
            return { RPAREN, ")", start_line, start_col };
        case '=':
            self.advance();
            return { EQUAL, "=", start_line, start_col };
        case ';':
            self.advance();
            return { SEMI, ";", start_line, start_col };
        case '+':
            self.advance();
            return { ADD, "+", start_line, start_col };
        case '-':
            self.advance();
            return { SUB, "-", start_line, start_col };
        case '*':
            self.advance();
            return { MUL, "*", start_line, start_col };
        case '/':
            self.advance();
            return { DIV, "/", start_line, start_col };
        case '\"':
            return { STRING, self.string(), start_line, start_col };
        default:
            io::printfn("Illegal character: %c", self.current_char);
            return { ILLEGAL, "", start_line, start_col };
        }
    }
    return { EOF, "", self.line, self.column };
}