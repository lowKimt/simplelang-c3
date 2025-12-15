module test_helper;
import lexer::tokens;

fn void assert_token(Token tok, TokenType expected_type, int expected_line, int expected_col) {
    assert(tok.type == expected_type);
    assert(tok.line == expected_line);
    assert(tok.column == expected_col);
}

fn void assert_token_full(Token tok, TokenType expected_type, String expected_lit, int expected_line, int expected_col) {
    assert(tok.type == expected_type);
    assert(tok.literal == expected_lit);
    assert(tok.line == expected_line);
    assert(tok.column == expected_col);
}
