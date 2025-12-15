import interpreter;
import lexer;
import parser;

// ============================================================================
// Let Statement Tests
// ============================================================================

fn void test_let_int() @test {
    Lexer lex = lexer::new_lexer("let x = 5");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 5, "x should be 5");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_let_str() @test {
    Lexer lex = lexer::new_lexer("let x = \"hello\"");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.s == "hello", "x should be \"hello\"");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_let_empty_str() @test {
    Lexer lex = lexer::new_lexer("let x = \"\"");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.s == "", "x should be empty string");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_let_multi() @test {
    Lexer lex = lexer::new_lexer("let x = 5\nlet y = 10");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 5, "x should be 5");
    assert(interpreter.globals.get("y")!!.value.i == 10, "y should be 10");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_let_to_var() @test {
    Lexer lex = lexer::new_lexer("let x = 5\nlet y = x");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 5, "x should be 5");
    assert(interpreter.globals.get("y")!!.value.i == 5, "y should be 5");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_let_zero() @test {
    Lexer lex = lexer::new_lexer("let x = 0");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 0, "x should be 0");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_let_negative_via_subtraction() @test {
    Lexer lex = lexer::new_lexer("let x = 0 - 5");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == -5, "x should be -5");

    pn.free(mem);
    interpreter.free(mem);
}

// ============================================================================
// Binary Operation Tests
// ============================================================================

fn void test_binop_add() @test {
    Lexer lex = lexer::new_lexer("let x = 5 + 3");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 8, "5 + 3 should be 8");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_sub() @test {
    Lexer lex = lexer::new_lexer("let x = 10 - 4");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 6, "10 - 4 should be 6");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_mul() @test {
    Lexer lex = lexer::new_lexer("let x = 6 * 7");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 42, "6 * 7 should be 42");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_div() @test {
    Lexer lex = lexer::new_lexer("let x = 20 / 4");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 5, "20 / 4 should be 5");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_div_truncation() @test {
    // Integer division should truncate
    Lexer lex = lexer::new_lexer("let x = 7 / 2");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 3, "7 / 2 should be 3 (truncated)");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_chained_add() @test {
    // Parser only supports one binary op per expression level, use parens
    Lexer lex = lexer::new_lexer("let x = (1 + 2) + 3");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 6, "(1 + 2) + 3 should be 6");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_mixed_ops() @test {
    Lexer lex = lexer::new_lexer("let x = 2 + 3 * 4");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    // * binds tighter than +, so 2 + (3 * 4) = 2 + 12 = 14
    assert(interpreter.globals.get("x")!!.value.i == 14, "2 + 3 * 4 should be 14");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_with_vars() @test {
    Lexer lex = lexer::new_lexer("let a = 10\nlet b = 20\nlet c = a + b");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("a")!!.value.i == 10, "a should be 10");
    assert(interpreter.globals.get("b")!!.value.i == 20, "b should be 20");
    assert(interpreter.globals.get("c")!!.value.i == 30, "a + b should be 30");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_sub_to_zero() @test {
    Lexer lex = lexer::new_lexer("let x = 5 - 5");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 0, "5 - 5 should be 0");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_mul_by_zero() @test {
    Lexer lex = lexer::new_lexer("let x = 100 * 0");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 0, "100 * 0 should be 0");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_binop_mul_by_one() @test {
    Lexer lex = lexer::new_lexer("let x = 42 * 1");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 42, "42 * 1 should be 42");

    pn.free(mem);
    interpreter.free(mem);
}

// ============================================================================
// Parenthesized Expression Tests
// ============================================================================

fn void test_paren_simple() @test {
    Lexer lex = lexer::new_lexer("let x = (5)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 5, "(5) should be 5");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_paren_with_binop() @test {
    Lexer lex = lexer::new_lexer("let x = (2 + 3)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 5, "(2 + 3) should be 5");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_paren_precedence_override() @test {
    // (2 + 3) * 4 = 20, whereas 2 + 3 * 4 would be 14 with standard precedence
    Lexer lex = lexer::new_lexer("let x = (2 + 3) * 4");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 20, "(2 + 3) * 4 should be 20");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_paren_nested() @test {
    Lexer lex = lexer::new_lexer("let x = ((5))");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 5, "((5)) should be 5");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_paren_complex() @test {
    Lexer lex = lexer::new_lexer("let x = (1 + 2) * (3 + 4)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 21, "(1 + 2) * (3 + 4) should be 21");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_paren_with_var() @test {
    Lexer lex = lexer::new_lexer("let a = 5\nlet x = (a + 3)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 8, "(a + 3) with a=5 should be 8");

    pn.free(mem);
    interpreter.free(mem);
}

// ============================================================================
// Variable Reference Tests
// ============================================================================

fn void test_var_reference_simple() @test {
    Lexer lex = lexer::new_lexer("let a = 42\nlet b = a");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("b")!!.value.i == 42, "b should copy value from a");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_var_reference_chain() @test {
    Lexer lex = lexer::new_lexer("let a = 1\nlet b = a\nlet c = b");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("a")!!.value.i == 1, "a should be 1");
    assert(interpreter.globals.get("b")!!.value.i == 1, "b should be 1");
    assert(interpreter.globals.get("c")!!.value.i == 1, "c should be 1");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_var_in_complex_expr() @test {
    Lexer lex = lexer::new_lexer("let a = 2\nlet b = 3\nlet c = a * b + 4");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    int result = interpreter.globals.get("c")!!.value.i;
    // Could be 10 (if * binds tighter) or 10 either way since 2*3+4 = 10
    assert(result == 10, "a * b + 4 with a=2, b=3 should be 10");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_var_string_reference() @test {
    Lexer lex = lexer::new_lexer("let s = \"world\"\nlet t = s");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("t")!!.value.s == "world", "t should copy string from s");

    pn.free(mem);
    interpreter.free(mem);
}

// ============================================================================
// Error Handling Tests
// ============================================================================

fn void test_undefined_variable() @test {
    Lexer lex = lexer::new_lexer("let x = undefined_var");
    Parser parser = parser::new_parser(&lex);
    
    if (try pn = parser.program()) {
        Interpreter interpreter = interpreter::new_interpreter();
        
        // Should fail with UNDEFINED_VARIABLE
        if (catch err = interpreter.visit_program(pn)) {
            assert(true, "Should error on undefined variable");
        } else {
            assert(false, "Expected error for undefined variable");
        }

        pn.free(mem);
        interpreter.free(mem);
    } else {
        assert(false, "Parser should not fail for this input");
    }
}

fn void test_division_by_zero() @test {
    Lexer lex = lexer::new_lexer("let x = 10 / 0");
    Parser parser = parser::new_parser(&lex);
    
    if (try pn = parser.program()) {
        Interpreter interpreter = interpreter::new_interpreter();
        
        // Should fail with DIVISION_BY_ZERO
        if (catch err = interpreter.visit_program(pn)) {
            assert(true, "Should error on division by zero");
        } else {
            assert(false, "Expected error for division by zero");
        }

        pn.free(mem);
        interpreter.free(mem);
    } else {
        assert(false, "Parser should not fail for this input");
    }
}

fn void test_division_by_zero_via_var() @test {
    Lexer lex = lexer::new_lexer("let z = 0\nlet x = 10 / z");
    Parser parser = parser::new_parser(&lex);
    
    if (try pn = parser.program()) {
        Interpreter interpreter = interpreter::new_interpreter();
        
        // Should fail with DIVISION_BY_ZERO
        if (catch err = interpreter.visit_program(pn)) {
            assert(true, "Should error on division by zero via variable");
        } else {
            assert(false, "Expected error for division by zero via variable");
        }

        pn.free(mem);
        interpreter.free(mem);
    } else {
        assert(false, "Parser should not fail for this input");
    }
}

// ============================================================================
// Edge Cases and Miscellaneous Tests
// ============================================================================

fn void test_large_number() @test {
    Lexer lex = lexer::new_lexer("let x = 999999");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 999999, "x should be 999999");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_many_variables() @test {
    Lexer lex = lexer::new_lexer("let a = 1\nlet b = 2\nlet c = 3\nlet d = 4\nlet e = 5");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("a")!!.value.i == 1, "a should be 1");
    assert(interpreter.globals.get("b")!!.value.i == 2, "b should be 2");
    assert(interpreter.globals.get("c")!!.value.i == 3, "c should be 3");
    assert(interpreter.globals.get("d")!!.value.i == 4, "d should be 4");
    assert(interpreter.globals.get("e")!!.value.i == 5, "e should be 5");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_reassign_variable() @test {
    // Test that a variable can be reassigned
    Lexer lex = lexer::new_lexer("let x = 1\nlet x = 2");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.i == 2, "x should be 2 after reassignment");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_self_reference_in_expr() @test {
    // let x = 5; let y = x + x
    Lexer lex = lexer::new_lexer("let x = 5\nlet y = x + x");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("y")!!.value.i == 10, "x + x with x=5 should be 10");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_string_with_spaces() @test {
    Lexer lex = lexer::new_lexer("let x = \"hello world\"");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    interpreter.visit_program(pn)!!;

    assert(interpreter.globals.get("x")!!.value.s == "hello world", "x should be \"hello world\"");

    pn.free(mem);
    interpreter.free(mem);
}

// ============================================================================
// Print Statement Tests
// ============================================================================

fn void test_print_int() @test {
    // Print an integer literal
    Lexer lex = lexer::new_lexer("print(42)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    // Should execute without error (prints to stdout)
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_string() @test {
    // Print a string literal
    Lexer lex = lexer::new_lexer("print(\"Hello, World!\")");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_empty_string() @test {
    Lexer lex = lexer::new_lexer("print(\"\")");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_variable_int() @test {
    // Print a variable containing an integer
    Lexer lex = lexer::new_lexer("let x = 100\nprint(x)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_variable_string() @test {
    // Print a variable containing a string
    Lexer lex = lexer::new_lexer("let msg = \"Greetings\"\nprint(msg)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_expression() @test {
    // Print the result of an expression
    Lexer lex = lexer::new_lexer("print(5 + 3)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_complex_expression() @test {
    // Print result of expression with precedence: 2 + 3 * 4 = 14
    Lexer lex = lexer::new_lexer("print(2 + 3 * 4)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_paren_expression() @test {
    // Print result of parenthesized expression: (2 + 3) * 4 = 20
    Lexer lex = lexer::new_lexer("print((2 + 3) * 4)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_var_expression() @test {
    // Print expression involving variables
    Lexer lex = lexer::new_lexer("let a = 10\nlet b = 5\nprint(a + b)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_multiple() @test {
    // Multiple print statements
    Lexer lex = lexer::new_lexer("print(1)\nprint(2)\nprint(3)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_zero() @test {
    Lexer lex = lexer::new_lexer("print(0)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_undefined_variable() @test {
    // Printing undefined variable should error
    Lexer lex = lexer::new_lexer("print(undefined_var)");
    Parser parser = parser::new_parser(&lex);
    
    if (try pn = parser.program()) {
        Interpreter interpreter = interpreter::new_interpreter();
        
        if (catch err = interpreter.visit_program(pn)) {
            assert(true, "Should error on undefined variable in print");
        } else {
            assert(false, "Expected error for undefined variable in print");
        }

        pn.free(mem);
        interpreter.free(mem);
    } else {
        assert(false, "Parser should not fail for this input");
    }
}

fn void test_print_division_by_zero() @test {
    // Division by zero in print expression should error
    Lexer lex = lexer::new_lexer("print(10 / 0)");
    Parser parser = parser::new_parser(&lex);
    
    if (try pn = parser.program()) {
        Interpreter interpreter = interpreter::new_interpreter();
        
        if (catch err = interpreter.visit_program(pn)) {
            assert(true, "Should error on division by zero in print");
        } else {
            assert(false, "Expected error for division by zero in print");
        }

        pn.free(mem);
        interpreter.free(mem);
    } else {
        assert(false, "Parser should not fail for this input");
    }
}

fn void test_mixed_let_and_print() @test {
    // Mix let statements and print statements
    Lexer lex = lexer::new_lexer("let x = 5\nprint(x)\nlet y = x * 2\nprint(y)");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;
    
    // Verify the variables are set correctly
    assert(interpreter.globals.get("x")!!.value.i == 5, "x should be 5");
    assert(interpreter.globals.get("y")!!.value.i == 10, "y should be 10");

    pn.free(mem);
    interpreter.free(mem);
}

fn void test_print_string_with_spaces() @test {
    Lexer lex = lexer::new_lexer("print(\"hello world\")");
    Parser parser = parser::new_parser(&lex);
    ProgramNode *pn = parser.program()!!;
    Interpreter interpreter = interpreter::new_interpreter();
    
    interpreter.visit_program(pn)!!;

    pn.free(mem);
    interpreter.free(mem);
}