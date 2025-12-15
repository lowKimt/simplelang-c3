module lexer::tokens;

enum TokenType {
    INT,
    STRING,
    IDENTIFIER,

    // General
    LPAREN,
    RPAREN,

    EQUAL,
    SEMI,
    
    // Operators
    ADD,
    SUB,
    MUL,
    DIV,
    
    // Keywords
    LET,
    PRINT,
    
    // Others
    ILLEGAL,
    EOF,
}

struct Token {
    TokenType type;
    String literal;
    int line;
    int column;
}