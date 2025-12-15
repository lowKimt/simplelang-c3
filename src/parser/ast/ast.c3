module parser::ast;

interface Node {
    fn void isNode();
    fn void free(Allocator allocator);
}

interface Expression : Node {
    fn void isExpr();
}

interface Statement : Node {
    fn void isStmt();
}

interface Program : Node {
    fn void isProgram();
}