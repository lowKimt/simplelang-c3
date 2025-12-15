import parser;
import parser::ast;
import lexer;
import std::io;
import std::core::mem::allocator;


// ============================================================================
// Literal Tests
// ============================================================================

fn void test_integer_literal() @test {
    Lexer l = lexer::new_lexer("let x = 42");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    assert(program.statements.len() == 1, "Expected 1 statement");
    
    // Get the statement and verify it's a LetStmt
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    assert(let_stmt.name == "x", "Expected name 'x'");
    
    // Verify the value is an Integer
    Integer* int_node = (Integer*)let_stmt.value;
    assert(int_node.value == 42, "Expected value 42");
    
    program.free(mem);
}

fn void test_string_literal() @test {
    Lexer l = lexer::new_lexer("let msg = \"hello\"");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    assert(program.statements.len() == 1, "Expected 1 statement");
    
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    assert(let_stmt.name == "msg", "Expected name 'msg'");
    
    StringNode* str_node = (StringNode*)let_stmt.value;
    assert(str_node.value == "hello", "Expected value 'hello'");
    
    program.free(mem);
}

fn void test_identifier() @test {
    Lexer l = lexer::new_lexer("let y = x");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    Identifier* id = (Identifier*)let_stmt.value;
    assert(id.value == "x", "Expected identifier 'x'");
    
    program.free(mem);
}

// ============================================================================
// Binary Operation Tests
// ============================================================================

fn void test_addition() @test {
    Lexer l = lexer::new_lexer("let sum = 1 + 2");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    BinOp* binop = (BinOp*)let_stmt.value;
    assert(binop.op == "+", "Expected operator '+'");
    
    Integer* left = (Integer*)binop.left;
    Integer* right = (Integer*)binop.right;
    assert(left.value == 1, "Expected left operand 1");
    assert(right.value == 2, "Expected right operand 2");
    
    program.free(mem);
}

fn void test_subtraction() @test {
    Lexer l = lexer::new_lexer("let diff = 10 - 3");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    BinOp* binop = (BinOp*)let_stmt.value;
    assert(binop.op == "-", "Expected operator '-'");
    
    Integer* left = (Integer*)binop.left;
    Integer* right = (Integer*)binop.right;
    assert(left.value == 10, "Expected left operand 10");
    assert(right.value == 3, "Expected right operand 3");
    
    program.free(mem);
}

fn void test_multiplication() @test {
    Lexer l = lexer::new_lexer("let prod = 4 * 5");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    BinOp* binop = (BinOp*)let_stmt.value;
    assert(binop.op == "*", "Expected operator '*'");
    
    Integer* left = (Integer*)binop.left;
    Integer* right = (Integer*)binop.right;
    assert(left.value == 4, "Expected left operand 4");
    assert(right.value == 5, "Expected right operand 5");
    
    program.free(mem);
}

fn void test_division() @test {
    Lexer l = lexer::new_lexer("let quot = 20 / 4");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    BinOp* binop = (BinOp*)let_stmt.value;
    assert(binop.op == "/", "Expected operator '/'");
    
    Integer* left = (Integer*)binop.left;
    Integer* right = (Integer*)binop.right;
    assert(left.value == 20, "Expected left operand 20");
    assert(right.value == 4, "Expected right operand 4");
    
    program.free(mem);
}

fn void test_mixed_operators() @test {
    // Tests precedence: 2 + 3 * 4 should parse as 2 + (3 * 4)
    Lexer l = lexer::new_lexer("let result = 2 + 3 * 4");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    // The outer operation should be addition (lower precedence)
    BinOp* add_op = (BinOp*)let_stmt.value;
    assert(add_op.op == "+", "Expected outer operator '+'");
    
    // Left should be 2
    Integer* left = (Integer*)add_op.left;
    assert(left.value == 2, "Expected left operand 2");
    
    // Right should be multiplication of 3 * 4
    BinOp* mul_op = (BinOp*)add_op.right;
    assert(mul_op.op == "*", "Expected inner operator '*'");
    
    Integer* mul_left = (Integer*)mul_op.left;
    Integer* mul_right = (Integer*)mul_op.right;
    assert(mul_left.value == 3, "Expected multiplication left operand 3");
    assert(mul_right.value == 4, "Expected multiplication right operand 4");
    
    program.free(mem);
}

// ============================================================================
// Parenthesized Expression Tests
// ============================================================================

fn void test_parenthesized_expression() @test {
    Lexer l = lexer::new_lexer("let val = (5)");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    ParenExpr* paren = (ParenExpr*)let_stmt.value;
    Integer* inner = (Integer*)paren.expr;
    assert(inner.value == 5, "Expected inner value 5");
    
    program.free(mem);
}

fn void test_parenthesized_binop() @test {
    // (2 + 3) * 4 - parentheses should group addition first
    Lexer l = lexer::new_lexer("let val = (2 + 3) * 4");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    // Outer operation should be multiplication
    BinOp* mul_op = (BinOp*)let_stmt.value;
    assert(mul_op.op == "*", "Expected outer operator '*'");
    
    // Left should be a parenthesized expression containing addition
    ParenExpr* paren = (ParenExpr*)mul_op.left;
    BinOp* add_op = (BinOp*)paren.expr;
    assert(add_op.op == "+", "Expected inner operator '+'");
    
    Integer* right = (Integer*)mul_op.right;
    assert(right.value == 4, "Expected right operand 4");
    
    program.free(mem);
}

// ============================================================================
// Statement Tests
// ============================================================================

fn void test_let_statement() @test {
    Lexer l = lexer::new_lexer("let foo = 123");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    assert(program.statements.len() == 1, "Expected 1 statement");
    
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    assert(let_stmt.name == "foo", "Expected name 'foo'");
    
    program.free(mem);
}

fn void test_print_statement() @test {
    Lexer l = lexer::new_lexer("print(42)");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    assert(program.statements.len() == 1, "Expected 1 statement");
    
    Statement stmt = program.statements[0];
    PrintStmt* print_stmt = (PrintStmt*)stmt;
    
    Integer* value = (Integer*)print_stmt.expr;
    assert(value.value == 42, "Expected print value 42");
    
    program.free(mem);
}

fn void test_print_expression() @test {
    Lexer l = lexer::new_lexer("print(1 + 2)");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    PrintStmt* print_stmt = (PrintStmt*)stmt;
    
    BinOp* binop = (BinOp*)print_stmt.expr;
    assert(binop.op == "+", "Expected operator '+'");
    
    program.free(mem);
}

fn void test_print_identifier() @test {
    Lexer l = lexer::new_lexer("print(myvar)");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    PrintStmt* print_stmt = (PrintStmt*)stmt;
    
    Identifier* id = (Identifier*)print_stmt.expr;
    assert(id.value == "myvar", "Expected identifier 'myvar'");
    
    program.free(mem);
}

fn void test_print_string() @test {
    Lexer l = lexer::new_lexer("print(\"hello world\")");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    PrintStmt* print_stmt = (PrintStmt*)stmt;
    
    StringNode* str = (StringNode*)print_stmt.expr;
    assert(str.value == "hello world", "Expected string 'hello world'");
    
    program.free(mem);
}

// ============================================================================
// Program Tests (Multiple Statements)
// ============================================================================

fn void test_multiple_statements() @test {
    Lexer l = lexer::new_lexer("let x = 1 let y = 2 let z = 3");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    assert(program.statements.len() == 3, "Expected 3 statements");
    
    // Verify each statement
    LetStmt* stmt1 = (LetStmt*)program.statements[0];
    LetStmt* stmt2 = (LetStmt*)program.statements[1];
    LetStmt* stmt3 = (LetStmt*)program.statements[2];
    
    assert(stmt1.name == "x", "Expected first statement name 'x'");
    assert(stmt2.name == "y", "Expected second statement name 'y'");
    assert(stmt3.name == "z", "Expected third statement name 'z'");
    
    program.free(mem);
}

fn void test_mixed_statements() @test {
    Lexer l = lexer::new_lexer("let x = 100 print(x)");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    assert(program.statements.len() == 2, "Expected 2 statements");
    
    // First statement is let
    LetStmt* let_stmt = (LetStmt*)program.statements[0];
    assert(let_stmt.name == "x", "Expected name 'x'");
    
    // Second statement is print
    PrintStmt* print_stmt = (PrintStmt*)program.statements[1];
    Identifier* id = (Identifier*)print_stmt.expr;
    assert(id.value == "x", "Expected print identifier 'x'");
    
    program.free(mem);
}

fn void test_complex_program() @test {
    Lexer l = lexer::new_lexer("let a = 10 let b = 20 let sum = a + b print(sum)");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    assert(program.statements.len() == 4, "Expected 4 statements");
    
    // Verify third statement has binary operation
    LetStmt* sum_stmt = (LetStmt*)program.statements[2];
    assert(sum_stmt.name == "sum", "Expected name 'sum'");
    
    BinOp* binop = (BinOp*)sum_stmt.value;
    assert(binop.op == "+", "Expected operator '+'");
    
    Identifier* left_id = (Identifier*)binop.left;
    Identifier* right_id = (Identifier*)binop.right;
    assert(left_id.value == "a", "Expected left identifier 'a'");
    assert(right_id.value == "b", "Expected right identifier 'b'");
    
    program.free(mem);
}

// ============================================================================
// Edge Case Tests
// ============================================================================


fn void test_nested_parentheses() @test {
    Lexer l = lexer::new_lexer("let val = ((5))");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    // Outer parentheses
    ParenExpr* outer = (ParenExpr*)let_stmt.value;
    // Inner parentheses
    ParenExpr* inner = (ParenExpr*)outer.expr;
    // Value
    Integer* val = (Integer*)inner.expr;
    assert(val.value == 5, "Expected nested value 5");
    
    program.free(mem);
}

fn void test_binop_with_identifiers() @test {
    Lexer l = lexer::new_lexer("let result = foo + bar");
    Parser p = parser::new_parser(&l);
    
    ProgramNode* program = p.program()!!;
    Statement stmt = program.statements[0];
    LetStmt* let_stmt = (LetStmt*)stmt;
    
    BinOp* binop = (BinOp*)let_stmt.value;
    assert(binop.op == "+", "Expected operator '+'");
    
    Identifier* left = (Identifier*)binop.left;
    Identifier* right = (Identifier*)binop.right;
    assert(left.value == "foo", "Expected left identifier 'foo'");
    assert(right.value == "bar", "Expected right identifier 'bar'");
    
    program.free(mem);
}
