import lexer;
import lexer::tokens;
import std::collections::list;
import test_helper;

fn void test_keyword() @test {
    Lexer l = lexer::new_lexer("let print");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token(t[0], LET, 1, 1);
    test_helper::assert_token(t[1], PRINT, 1, 5);

    t.free();
}

fn void test_ops() @test {
    Lexer l = lexer::new_lexer("(+-*/);");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token(t[0], LPAREN, 1, 1);
    test_helper::assert_token(t[1], ADD, 1, 2);
    test_helper::assert_token(t[2], SUB, 1, 3);
    test_helper::assert_token(t[3], MUL, 1, 4);
    test_helper::assert_token(t[4], DIV, 1, 5);
    test_helper::assert_token(t[5], RPAREN, 1, 6);
    test_helper::assert_token(t[6], SEMI, 1, 7);

    t.free();
}

fn void test_numbers() @test {
    Lexer l = lexer::new_lexer("123;456");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token(t[0], INT, 1, 1);
    test_helper::assert_token(t[1], SEMI, 1, 4);
    test_helper::assert_token(t[2], INT, 1, 5);

    t.free();
}

fn void test_string() @test {
    Lexer l = lexer::new_lexer("\"hello\";\"world\"");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token(t[0], STRING, 1, 1);
    test_helper::assert_token(t[1], SEMI, 1, 8);
    test_helper::assert_token(t[2], STRING, 1, 9);

    t.free();
}

fn void test_equal() @test {
    Lexer l = lexer::new_lexer("x = 5");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token(t[0], IDENTIFIER, 1, 1);
    test_helper::assert_token(t[1], EQUAL, 1, 3);
    test_helper::assert_token(t[2], INT, 1, 5);

    t.free();
}

fn void test_identifier() @test {
    Lexer l = lexer::new_lexer("foo bar myvar");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token_full(t[0], IDENTIFIER, "foo", 1, 1);
    test_helper::assert_token_full(t[1], IDENTIFIER, "bar", 1, 5);
    test_helper::assert_token_full(t[2], IDENTIFIER, "myvar", 1, 9);

    t.free();
}

fn void test_multiline() @test {
    Lexer l = lexer::new_lexer("let\nx\n123");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token(t[0], LET, 1, 1);
    test_helper::assert_token(t[1], IDENTIFIER, 2, 1);
    test_helper::assert_token(t[2], INT, 3, 1);

    t.free();
}

fn void test_illegal() @test {
    Lexer l = lexer::new_lexer("@");
    Token tok = l.next_token();

    assert(tok.type == ILLEGAL);
    assert(tok.line == 1);
    assert(tok.column == 1);
}

fn void test_whitespace_only() @test {
    Lexer l = lexer::new_lexer("   \t\n  ");
    Token tok = l.next_token();

    // After consuming all whitespace, should return EOF
    assert(tok.type == EOF);
}

fn void test_empty_string_literal() @test {
    Lexer l = lexer::new_lexer("\"\"");
    Token tok = l.next_token();

    test_helper::assert_token_full(tok, STRING, "", 1, 1);
}

fn void test_keyword_prefix_identifier() @test {
    // "letx" should be IDENTIFIER "letx", not LET + IDENTIFIER "x"
    Lexer l = lexer::new_lexer("letx printable");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token_full(t[0], IDENTIFIER, "letx", 1, 1);
    test_helper::assert_token_full(t[1], IDENTIFIER, "printable", 1, 6);

    t.free();
}

fn void test_number_literals() @test {
    Lexer l = lexer::new_lexer("0 007 42");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token_full(t[0], INT, "0", 1, 1);
    test_helper::assert_token_full(t[1], INT, "007", 1, 3);
    test_helper::assert_token_full(t[2], INT, "42", 1, 7);

    t.free();
}

fn void test_full_statement() @test {
    // A realistic statement: let x = 5 + 3;
    Lexer l = lexer::new_lexer("let x = 5 + 3;");
    List{Token} t;

    for (int i = 0; i < l.input.len; i++) {
        t.push(l.next_token());

        if (try tok = t.last()) {
            if (tok.type == EOF) break;
        }
    }

    test_helper::assert_token_full(t[0], LET, "let", 1, 1);
    test_helper::assert_token_full(t[1], IDENTIFIER, "x", 1, 5);
    test_helper::assert_token_full(t[2], EQUAL, "=", 1, 7);
    test_helper::assert_token_full(t[3], INT, "5", 1, 9);
    test_helper::assert_token_full(t[4], ADD, "+", 1, 11);
    test_helper::assert_token_full(t[5], INT, "3", 1, 13);
    test_helper::assert_token_full(t[6], SEMI, ";", 1, 14);

    t.free();
}