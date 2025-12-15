module interpreter;
import std::collections::map;
import parser;
import parser::ast;
import std::io;

faultdef INVALID_NODE_TYPE;
faultdef UNDEFINED_VARIABLE;
faultdef DIVISION_BY_ZERO;

enum VTypes @private {
    T_INT,
    T_STR,
}

struct Value @private {
    VTypes type;
    union value {
        int i;
        String s;
    }
}

struct Interpreter {
    HashMap{String, Value} *globals;
}

fn Interpreter new_interpreter() {
    Interpreter i;
    i.globals = allocator::new(mem, HashMap{String, Value});
    i.globals.init(mem);
    return i;
}

fn void Interpreter.free(Interpreter *self, Allocator allocator) 
{
    self.globals.free();
    allocator::free(allocator, self.globals);
}

fn void? Interpreter.visit_program(Interpreter *self, ast::ProgramNode *pn) 
{
    foreach (Statement stmt : pn.statements) {
        self.visit_stmt(stmt)!;
    }
}

fn void? Interpreter.visit_stmt(Interpreter *self, ast::Statement stmt) 
{
    switch (stmt.type) {
        case ast::LetStmt:
            self.visit_let_stmt((LetStmt*)stmt.ptr)!;
            break;
        case ast::PrintStmt:
            self.visit_print_stmt((PrintStmt*)stmt.ptr)!;
            break;
        default:
            io::eprintfn("Invalid node type %d", stmt.type);
            return INVALID_NODE_TYPE?;
    }
}

fn void? Interpreter.visit_let_stmt(Interpreter *self, ast::LetStmt *stmt) 
{
    Value value = self.visit_expr(stmt.value)!;
    self.globals.set(stmt.name, value);
}

fn void? Interpreter.visit_print_stmt(Interpreter *self, ast::PrintStmt *stmt) 
{
    Value value = self.visit_expr(stmt.expr)!;
    switch (value.type) {
        case T_INT:
            io::printfn("%d", value.value.i);
            break;
        case T_STR:
            io::printfn("%s", value.value.s);
            break;
        default:
            io::eprintfn("Invalid value type %d", value.type);
            return INVALID_NODE_TYPE?;
    }
}

fn Value? Interpreter.visit_expr(Interpreter *self, ast::Expression expr) 
{
    switch (expr.type) {
        case ast::BinOp:
            return { .type = T_INT, .value.i = self.visit_binop_expr((BinOp*)expr.ptr)! };
        case ast::ParenExpr:
            return self.visit_paren_expr((ParenExpr*)expr.ptr)!;
        case ast::Integer:
            return { .type = T_INT, .value.i = self.visit_integer((Integer*)expr.ptr) };
        case ast::Identifier:
            return self.visit_identifier((Identifier*)expr.ptr)!;
        case ast::StringNode:
            return { .type = T_STR, .value.s = self.visit_string((StringNode*)expr.ptr) };
        default:
            io::eprintfn("Invalid node type %d", expr.type);
            return INVALID_NODE_TYPE?;
    }
}

fn int? Interpreter.visit_binop_expr(Interpreter *self, ast::BinOp *expr) 
{
    Value left = self.visit_expr(expr.left)!;
    Value right = self.visit_expr(expr.right)!;
    
    if (left.type != T_INT || right.type != T_INT) {
        io::eprintfn("Invalid types for binop %s, %s", left.type, right.type);
        return INVALID_NODE_TYPE?;
    }
    
    switch (expr.op) {
        case "+":
            return left.value.i + right.value.i;
        case "-":
            return left.value.i - right.value.i;
        case "*":
            return left.value.i * right.value.i;
        case "/":
            if (right.value.i == 0) {
                io::eprintfn("Division by zero");
                return DIVISION_BY_ZERO?;
            }
            return left.value.i / right.value.i;
        default:
            io::eprintfn("Invalid operator %s", expr.op);
            return INVALID_NODE_TYPE?;
    }    
}

fn Value? Interpreter.visit_paren_expr(Interpreter *self, ast::ParenExpr *expr) 
{
    return self.visit_expr(expr.expr)!;
}

fn int Interpreter.visit_integer(Interpreter *self, ast::Integer *integer) 
{
    return integer.value;
}

fn Value? Interpreter.visit_identifier(Interpreter *self, ast::Identifier *identifier) 
{
    if (self.globals.has_key(identifier.value)) {
        return self.globals.get(identifier.value)!;
    }
    io::eprintfn("Undefined variable %s", identifier.value);
    return UNDEFINED_VARIABLE?;
}

fn String Interpreter.visit_string(Interpreter *self, ast::StringNode *string) 
{
    return string.value;
}