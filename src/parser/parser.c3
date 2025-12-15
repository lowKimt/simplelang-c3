module parser;
import lexer;
import std::io;
import std::collections::list;
import std::core::mem::allocator;

faultdef INVALID_TOKEN_TYPE;
faultdef INVALID_STATEMENT;

struct Parser {
    Allocator allocator;
    Lexer *lexer;
    Token current_token;
    int line;
    int column;
}


fn Parser new_parser(Lexer *lexer) {
    Parser p;
    p.allocator = mem;
    p.lexer = lexer;
    p.current_token = lexer.next_token();
    p.update_pos();
    return p;
}

fn void Parser.update_pos(Parser *self) @private 
{
    self.line = self.lexer.line;
    self.column = self.lexer.column;
}

fn void Parser.reset(Parser *self) 
{
    self.current_token = self.lexer.next_token();
    self.update_pos();
}

fn void? Parser.eat(Parser *self, TokenType type) 
{
    if (self.current_token.type == type) {
        self.current_token = self.lexer.next_token();
        self.update_pos();
    } else {
        io::eprintfn("Expected %s at (L%d:C%d), got %s", type, self.line, self.column, self.current_token.type);
        return INVALID_TOKEN_TYPE?;
    }
}

fn ProgramNode*? Parser.program(Parser *self) 
{
    List{Statement} statements;

    while (self.current_token.type != EOF) 
    {
        statements.push(self.statement()!);
    }

    return allocator::new(self.allocator, ProgramNode, { .statements = statements });
}

fn Statement? Parser.statement(Parser *self) 
{
    switch (self.current_token.type) 
    {
        case LET:
            self.eat(LET)!;
            String name = self.current_token.literal.tcopy();
            self.eat(IDENTIFIER)!;
            self.eat(EQUAL)!;
            Expression value = self.expression()!;
            return allocator::new(self.allocator, LetStmt, {.name = name, .value = value});
            
        case PRINT:
            self.eat(PRINT)!;
            self.eat(LPAREN)!;
            Expression expr = self.expression()!;
            self.eat(RPAREN)!;
            return allocator::new(self.allocator, PrintStmt, {.expr = expr});
            
        default:
            io::eprintfn("Expected statement, got %s at (L%d:C%d)", self.current_token.literal, self.line, self.column);
            return INVALID_STATEMENT?;
    }
}

fn Expression? Parser.factor(Parser *self) 
{
    switch (self.current_token.type) {
        case LPAREN:
            self.eat(LPAREN)!;
            Expression expr = self.expression()!;
            self.eat(RPAREN)!;
            return allocator::new(self.allocator, ParenExpr, {.expr = expr});
        case IDENTIFIER:
            String name = self.current_token.literal.tcopy();
            self.eat(IDENTIFIER)!;
            return (Expression)allocator::new(self.allocator, Identifier, {.value = name});
        default:
            return (Expression)self.literal()!;
    }
}

fn Expression? Parser.term(Parser *self) 
{
    Expression left = self.factor()!;

    switch (self.current_token.type) {
        case MUL:
            self.eat(MUL)!;
            Expression right = self.factor()!;
            return allocator::new(self.allocator, BinOp, {.left = left, .op = "*", .right = right});
        case DIV:
            self.eat(DIV)!;
            Expression right = self.factor()!;
            return allocator::new(self.allocator, BinOp, {.left = left, .op = "/", .right = right});
        default:
            return left;
    }
}

fn Expression? Parser.expression(Parser *self) 
{
    Expression left = self.term()!;

    switch (self.current_token.type) {
        case ADD:
            self.eat(ADD)!;
            Expression right = self.term()!;
            return allocator::new(self.allocator, BinOp, {.left = left, .op = "+", .right = right});
        case SUB:
            self.eat(SUB)!;
            Expression right = self.term()!;
            return allocator::new(self.allocator, BinOp, {.left = left, .op = "-", .right = right});
        default:
            return left;
    }
}

fn Node? Parser.literal(Parser *self) 
{
    switch (self.current_token.type) {
        case INT:
            int resint = self.current_token.literal.to_int()?? INVALID_TOKEN_TYPE?!;
            self.eat(INT)!;
            return allocator::new(self.allocator, Integer, {.value = resint});
        case STRING:
            String resstr = self.current_token.literal.tcopy();
            self.eat(STRING)!;
            return allocator::new(self.allocator, StringNode, {.value = resstr});
        default:
            io::eprintfn("Invalid token %s at (L%d:C%d)", self.current_token.literal, self.line, self.column);
            return INVALID_TOKEN_TYPE?;
    }
}