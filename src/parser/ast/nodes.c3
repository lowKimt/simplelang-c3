module parser::ast;
import std::collections::list;


struct Integer (Node) {
    int value;
}

fn void Integer.isNode(Integer *self) @dynamic {}
fn void Integer.free(Integer *self, Allocator allocator) @dynamic {
    allocator::free(allocator, self);
}

struct Identifier (Node) {
    String value;
}

fn void Identifier.isNode(Identifier *self) @dynamic {}
fn void Identifier.free(Identifier *self, Allocator allocator) @dynamic {
    allocator::free(allocator, self);
}

struct StringNode (Node) {
    String value;
}

fn void StringNode.isNode(StringNode *self) @dynamic {}
fn void StringNode.free(StringNode *self, Allocator allocator) @dynamic 
{
    allocator::free(allocator, self);
}

// Expressions

struct BinOp (Expression) {
    Expression left;
    String op;
    Expression right;
}

fn void BinOp.isNode(BinOp *self) @dynamic {}
fn void BinOp.isExpr(BinOp *self) @dynamic {}
fn void BinOp.free(BinOp *self, Allocator allocator) @dynamic 
{
    self.left.free(allocator);
    self.right.free(allocator);
    allocator::free(allocator, self);
}

struct ParenExpr (Expression) {
    Expression expr;
}

fn void ParenExpr.isNode(ParenExpr *self) @dynamic {}
fn void ParenExpr.isExpr(ParenExpr *self) @dynamic {}
fn void ParenExpr.free(ParenExpr *self, Allocator allocator) @dynamic 
{
    self.expr.free(allocator);
    allocator::free(allocator, self);
}

// Statements

struct LetStmt (Statement) {
    String name;
    Expression value;
}

fn void LetStmt.isNode(LetStmt *self) @dynamic {}
fn void LetStmt.isStmt(LetStmt *self) @dynamic {}
fn void LetStmt.free(LetStmt *self, Allocator allocator) @dynamic 
{
    self.value.free(allocator);
    allocator::free(allocator, self);
}

struct PrintStmt (Statement) 
{
    Expression expr;
}

fn void PrintStmt.isNode(PrintStmt *self) @dynamic {}
fn void PrintStmt.isStmt(PrintStmt *self) @dynamic {}
fn void PrintStmt.free(PrintStmt *self, Allocator allocator) @dynamic 
{
    self.expr.free(allocator);
    allocator::free(allocator, self);
}

// Program

struct ProgramNode (Program) 
{
    List{Statement} statements;
}

fn void ProgramNode.isNode(ProgramNode *self) @dynamic {}
fn void ProgramNode.isProgram(ProgramNode *self) @dynamic {}
fn void ProgramNode.free(ProgramNode *self, Allocator allocator) @dynamic 
{
    foreach (Statement stmt : self.statements) 
    {
        stmt.free(allocator);
    }
    self.statements.free();
    allocator::free(allocator, self);
}