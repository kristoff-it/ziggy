#include <tree_sitter/parser.h>

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 13
#define STATE_COUNT 114
#define LARGE_STATE_COUNT 2
#define SYMBOL_COUNT 42
#define ALIAS_COUNT 0
#define TOKEN_COUNT 22
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 3
#define MAX_ALIAS_SEQUENCE_LENGTH 7
#define PRODUCTION_ID_COUNT 6

enum {
  anon_sym_COMMA = 1,
  anon_sym_LBRACE = 2,
  anon_sym_RBRACE = 3,
  anon_sym_DOT = 4,
  anon_sym_EQ = 5,
  anon_sym_COLON = 6,
  anon_sym_LBRACK = 7,
  anon_sym_RBRACK = 8,
  anon_sym_AT = 9,
  anon_sym_LPAREN = 10,
  anon_sym_RPAREN = 11,
  aux_sym_tag_token1 = 12,
  anon_sym_DQUOTE = 13,
  aux_sym_string_content_token1 = 14,
  sym_escape_sequence = 15,
  sym_identifier = 16,
  sym_number = 17,
  sym_true = 18,
  sym_false = 19,
  sym_null = 20,
  aux_sym_comment_token1 = 21,
  sym_document = 22,
  sym__value = 23,
  sym_top_level_struct = 24,
  sym_struct = 25,
  sym_map = 26,
  sym_struct_field = 27,
  sym_map_field = 28,
  sym_array = 29,
  sym_array_elem = 30,
  sym_tag_string = 31,
  sym_tag = 32,
  sym_string = 33,
  sym_string_content = 34,
  sym_comment = 35,
  aux_sym_top_level_struct_repeat1 = 36,
  aux_sym_map_repeat1 = 37,
  aux_sym_array_repeat1 = 38,
  aux_sym_tag_repeat1 = 39,
  aux_sym_string_content_repeat1 = 40,
  aux_sym_comment_repeat1 = 41,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [anon_sym_COMMA] = ",",
  [anon_sym_LBRACE] = "{",
  [anon_sym_RBRACE] = "}",
  [anon_sym_DOT] = ".",
  [anon_sym_EQ] = "=",
  [anon_sym_COLON] = ":",
  [anon_sym_LBRACK] = "[",
  [anon_sym_RBRACK] = "]",
  [anon_sym_AT] = "@",
  [anon_sym_LPAREN] = "(",
  [anon_sym_RPAREN] = ")",
  [aux_sym_tag_token1] = "tag_token1",
  [anon_sym_DQUOTE] = "\"",
  [aux_sym_string_content_token1] = "string_content_token1",
  [sym_escape_sequence] = "escape_sequence",
  [sym_identifier] = "identifier",
  [sym_number] = "number",
  [sym_true] = "true",
  [sym_false] = "false",
  [sym_null] = "null",
  [aux_sym_comment_token1] = "comment_token1",
  [sym_document] = "document",
  [sym__value] = "_value",
  [sym_top_level_struct] = "top_level_struct",
  [sym_struct] = "struct",
  [sym_map] = "map",
  [sym_struct_field] = "struct_field",
  [sym_map_field] = "map_field",
  [sym_array] = "array",
  [sym_array_elem] = "array_elem",
  [sym_tag_string] = "tag_string",
  [sym_tag] = "tag",
  [sym_string] = "string",
  [sym_string_content] = "string_content",
  [sym_comment] = "comment",
  [aux_sym_top_level_struct_repeat1] = "top_level_struct_repeat1",
  [aux_sym_map_repeat1] = "map_repeat1",
  [aux_sym_array_repeat1] = "array_repeat1",
  [aux_sym_tag_repeat1] = "tag_repeat1",
  [aux_sym_string_content_repeat1] = "string_content_repeat1",
  [aux_sym_comment_repeat1] = "comment_repeat1",
};

static const TSSymbol ts_symbol_map[] = {
  [ts_builtin_sym_end] = ts_builtin_sym_end,
  [anon_sym_COMMA] = anon_sym_COMMA,
  [anon_sym_LBRACE] = anon_sym_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
  [anon_sym_DOT] = anon_sym_DOT,
  [anon_sym_EQ] = anon_sym_EQ,
  [anon_sym_COLON] = anon_sym_COLON,
  [anon_sym_LBRACK] = anon_sym_LBRACK,
  [anon_sym_RBRACK] = anon_sym_RBRACK,
  [anon_sym_AT] = anon_sym_AT,
  [anon_sym_LPAREN] = anon_sym_LPAREN,
  [anon_sym_RPAREN] = anon_sym_RPAREN,
  [aux_sym_tag_token1] = aux_sym_tag_token1,
  [anon_sym_DQUOTE] = anon_sym_DQUOTE,
  [aux_sym_string_content_token1] = aux_sym_string_content_token1,
  [sym_escape_sequence] = sym_escape_sequence,
  [sym_identifier] = sym_identifier,
  [sym_number] = sym_number,
  [sym_true] = sym_true,
  [sym_false] = sym_false,
  [sym_null] = sym_null,
  [aux_sym_comment_token1] = aux_sym_comment_token1,
  [sym_document] = sym_document,
  [sym__value] = sym__value,
  [sym_top_level_struct] = sym_top_level_struct,
  [sym_struct] = sym_struct,
  [sym_map] = sym_map,
  [sym_struct_field] = sym_struct_field,
  [sym_map_field] = sym_map_field,
  [sym_array] = sym_array,
  [sym_array_elem] = sym_array_elem,
  [sym_tag_string] = sym_tag_string,
  [sym_tag] = sym_tag,
  [sym_string] = sym_string,
  [sym_string_content] = sym_string_content,
  [sym_comment] = sym_comment,
  [aux_sym_top_level_struct_repeat1] = aux_sym_top_level_struct_repeat1,
  [aux_sym_map_repeat1] = aux_sym_map_repeat1,
  [aux_sym_array_repeat1] = aux_sym_array_repeat1,
  [aux_sym_tag_repeat1] = aux_sym_tag_repeat1,
  [aux_sym_string_content_repeat1] = aux_sym_string_content_repeat1,
  [aux_sym_comment_repeat1] = aux_sym_comment_repeat1,
};

static const TSSymbolMetadata ts_symbol_metadata[] = {
  [ts_builtin_sym_end] = {
    .visible = false,
    .named = true,
  },
  [anon_sym_COMMA] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_LBRACE] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_RBRACE] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_DOT] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_EQ] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_COLON] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_LBRACK] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_RBRACK] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_AT] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_LPAREN] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_RPAREN] = {
    .visible = true,
    .named = false,
  },
  [aux_sym_tag_token1] = {
    .visible = false,
    .named = false,
  },
  [anon_sym_DQUOTE] = {
    .visible = true,
    .named = false,
  },
  [aux_sym_string_content_token1] = {
    .visible = false,
    .named = false,
  },
  [sym_escape_sequence] = {
    .visible = true,
    .named = true,
  },
  [sym_identifier] = {
    .visible = true,
    .named = true,
  },
  [sym_number] = {
    .visible = true,
    .named = true,
  },
  [sym_true] = {
    .visible = true,
    .named = true,
  },
  [sym_false] = {
    .visible = true,
    .named = true,
  },
  [sym_null] = {
    .visible = true,
    .named = true,
  },
  [aux_sym_comment_token1] = {
    .visible = false,
    .named = false,
  },
  [sym_document] = {
    .visible = true,
    .named = true,
  },
  [sym__value] = {
    .visible = false,
    .named = true,
  },
  [sym_top_level_struct] = {
    .visible = true,
    .named = true,
  },
  [sym_struct] = {
    .visible = true,
    .named = true,
  },
  [sym_map] = {
    .visible = true,
    .named = true,
  },
  [sym_struct_field] = {
    .visible = true,
    .named = true,
  },
  [sym_map_field] = {
    .visible = true,
    .named = true,
  },
  [sym_array] = {
    .visible = true,
    .named = true,
  },
  [sym_array_elem] = {
    .visible = true,
    .named = true,
  },
  [sym_tag_string] = {
    .visible = true,
    .named = true,
  },
  [sym_tag] = {
    .visible = true,
    .named = true,
  },
  [sym_string] = {
    .visible = true,
    .named = true,
  },
  [sym_string_content] = {
    .visible = true,
    .named = true,
  },
  [sym_comment] = {
    .visible = true,
    .named = true,
  },
  [aux_sym_top_level_struct_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_map_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_array_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_tag_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_string_content_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_comment_repeat1] = {
    .visible = false,
    .named = false,
  },
};

enum {
  field_key = 1,
  field_name = 2,
  field_value = 3,
};

static const char * const ts_field_names[] = {
  [0] = NULL,
  [field_key] = "key",
  [field_name] = "name",
  [field_value] = "value",
};

static const TSFieldMapSlice ts_field_map_slices[PRODUCTION_ID_COUNT] = {
  [1] = {.index = 0, .length = 1},
  [2] = {.index = 1, .length = 2},
  [3] = {.index = 3, .length = 2},
  [4] = {.index = 5, .length = 1},
  [5] = {.index = 6, .length = 2},
};

static const TSFieldMapEntry ts_field_map_entries[] = {
  [0] =
    {field_name, 0},
  [1] =
    {field_key, 0},
    {field_value, 2},
  [3] =
    {field_key, 1},
    {field_value, 3},
  [5] =
    {field_name, 1},
  [6] =
    {field_key, 2},
    {field_value, 4},
};

static const TSSymbol ts_alias_sequences[PRODUCTION_ID_COUNT][MAX_ALIAS_SEQUENCE_LENGTH] = {
  [0] = {0},
};

static const uint16_t ts_non_terminal_alias_map[] = {
  0,
};

static bool ts_lex(TSLexer *lexer, TSStateId state) {
  START_LEXER();
  eof = lexer->eof(lexer);
  switch (state) {
    case 0:
      if (eof) ADVANCE(11);
      if (lookahead == '"') ADVANCE(24);
      if (lookahead == '(') ADVANCE(21);
      if (lookahead == ')') ADVANCE(22);
      if (lookahead == ',') ADVANCE(12);
      if (lookahead == '-') ADVANCE(5);
      if (lookahead == '.') ADVANCE(15);
      if (lookahead == '/') ADVANCE(4);
      if (lookahead == '0') ADVANCE(39);
      if (lookahead == ':') ADVANCE(17);
      if (lookahead == '=') ADVANCE(16);
      if (lookahead == '@') ADVANCE(20);
      if (lookahead == '[') ADVANCE(18);
      if (lookahead == '\\') ADVANCE(7);
      if (lookahead == ']') ADVANCE(19);
      if (lookahead == '{') ADVANCE(13);
      if (lookahead == '}') ADVANCE(14);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(9)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(40);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(23);
      END_STATE();
    case 1:
      if (lookahead == '\n') SKIP(2)
      if (lookahead == '"') ADVANCE(24);
      if (lookahead == '\\') ADVANCE(7);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(25);
      if (lookahead != 0) ADVANCE(26);
      END_STATE();
    case 2:
      if (lookahead == '"') ADVANCE(24);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(2)
      END_STATE();
    case 3:
      if (lookahead == '-') ADVANCE(8);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(42);
      END_STATE();
    case 4:
      if (lookahead == '/') ADVANCE(46);
      END_STATE();
    case 5:
      if (lookahead == '0') ADVANCE(39);
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(40);
      END_STATE();
    case 6:
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(6)
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 7:
      if (lookahead == '"' ||
          lookahead == '/' ||
          lookahead == '\\' ||
          lookahead == 'b' ||
          lookahead == 'f' ||
          lookahead == 'n' ||
          lookahead == 'r' ||
          lookahead == 't' ||
          lookahead == 'u') ADVANCE(27);
      END_STATE();
    case 8:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(42);
      END_STATE();
    case 9:
      if (eof) ADVANCE(11);
      if (lookahead == '"') ADVANCE(24);
      if (lookahead == '(') ADVANCE(21);
      if (lookahead == ')') ADVANCE(22);
      if (lookahead == ',') ADVANCE(12);
      if (lookahead == '-') ADVANCE(5);
      if (lookahead == '.') ADVANCE(15);
      if (lookahead == '/') ADVANCE(4);
      if (lookahead == '0') ADVANCE(39);
      if (lookahead == ':') ADVANCE(17);
      if (lookahead == '=') ADVANCE(16);
      if (lookahead == '@') ADVANCE(20);
      if (lookahead == '[') ADVANCE(18);
      if (lookahead == ']') ADVANCE(19);
      if (lookahead == '{') ADVANCE(13);
      if (lookahead == '}') ADVANCE(14);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(9)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(40);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(23);
      END_STATE();
    case 10:
      if (eof) ADVANCE(11);
      if (lookahead == '"') ADVANCE(24);
      if (lookahead == '-') ADVANCE(5);
      if (lookahead == '.') ADVANCE(15);
      if (lookahead == '/') ADVANCE(4);
      if (lookahead == '0') ADVANCE(39);
      if (lookahead == '@') ADVANCE(20);
      if (lookahead == '[') ADVANCE(18);
      if (lookahead == ']') ADVANCE(19);
      if (lookahead == 'f') ADVANCE(28);
      if (lookahead == 'n') ADVANCE(37);
      if (lookahead == 't') ADVANCE(34);
      if (lookahead == '{') ADVANCE(13);
      if (lookahead == '}') ADVANCE(14);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(10)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(40);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 11:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 12:
      ACCEPT_TOKEN(anon_sym_COMMA);
      END_STATE();
    case 13:
      ACCEPT_TOKEN(anon_sym_LBRACE);
      END_STATE();
    case 14:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 15:
      ACCEPT_TOKEN(anon_sym_DOT);
      END_STATE();
    case 16:
      ACCEPT_TOKEN(anon_sym_EQ);
      END_STATE();
    case 17:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 18:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 19:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(anon_sym_AT);
      END_STATE();
    case 21:
      ACCEPT_TOKEN(anon_sym_LPAREN);
      END_STATE();
    case 22:
      ACCEPT_TOKEN(anon_sym_RPAREN);
      END_STATE();
    case 23:
      ACCEPT_TOKEN(aux_sym_tag_token1);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(anon_sym_DQUOTE);
      END_STATE();
    case 25:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(25);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(26);
      END_STATE();
    case 26:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(26);
      END_STATE();
    case 27:
      ACCEPT_TOKEN(sym_escape_sequence);
      END_STATE();
    case 28:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'a') ADVANCE(31);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('b' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 29:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'e') ADVANCE(43);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 30:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'e') ADVANCE(44);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 31:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'l') ADVANCE(35);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 32:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'l') ADVANCE(45);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 33:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'l') ADVANCE(32);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 34:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'r') ADVANCE(36);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 35:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 's') ADVANCE(30);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 36:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'u') ADVANCE(29);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 37:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'u') ADVANCE(33);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 38:
      ACCEPT_TOKEN(sym_identifier);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 39:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(41);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(3);
      END_STATE();
    case 40:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(41);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(3);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(40);
      END_STATE();
    case 41:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(3);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(41);
      END_STATE();
    case 42:
      ACCEPT_TOKEN(sym_number);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(42);
      END_STATE();
    case 43:
      ACCEPT_TOKEN(sym_true);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 44:
      ACCEPT_TOKEN(sym_false);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 45:
      ACCEPT_TOKEN(sym_null);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(38);
      END_STATE();
    case 46:
      ACCEPT_TOKEN(aux_sym_comment_token1);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(46);
      END_STATE();
    default:
      return false;
  }
}

static const TSLexMode ts_lex_modes[STATE_COUNT] = {
  [0] = {.lex_state = 0},
  [1] = {.lex_state = 10},
  [2] = {.lex_state = 10},
  [3] = {.lex_state = 10},
  [4] = {.lex_state = 10},
  [5] = {.lex_state = 10},
  [6] = {.lex_state = 10},
  [7] = {.lex_state = 10},
  [8] = {.lex_state = 10},
  [9] = {.lex_state = 10},
  [10] = {.lex_state = 10},
  [11] = {.lex_state = 10},
  [12] = {.lex_state = 10},
  [13] = {.lex_state = 10},
  [14] = {.lex_state = 10},
  [15] = {.lex_state = 10},
  [16] = {.lex_state = 0},
  [17] = {.lex_state = 0},
  [18] = {.lex_state = 0},
  [19] = {.lex_state = 0},
  [20] = {.lex_state = 0},
  [21] = {.lex_state = 0},
  [22] = {.lex_state = 0},
  [23] = {.lex_state = 0},
  [24] = {.lex_state = 0},
  [25] = {.lex_state = 0},
  [26] = {.lex_state = 0},
  [27] = {.lex_state = 0},
  [28] = {.lex_state = 0},
  [29] = {.lex_state = 0},
  [30] = {.lex_state = 0},
  [31] = {.lex_state = 0},
  [32] = {.lex_state = 0},
  [33] = {.lex_state = 0},
  [34] = {.lex_state = 0},
  [35] = {.lex_state = 0},
  [36] = {.lex_state = 0},
  [37] = {.lex_state = 0},
  [38] = {.lex_state = 0},
  [39] = {.lex_state = 0},
  [40] = {.lex_state = 0},
  [41] = {.lex_state = 0},
  [42] = {.lex_state = 0},
  [43] = {.lex_state = 0},
  [44] = {.lex_state = 0},
  [45] = {.lex_state = 0},
  [46] = {.lex_state = 0},
  [47] = {.lex_state = 0},
  [48] = {.lex_state = 0},
  [49] = {.lex_state = 0},
  [50] = {.lex_state = 0},
  [51] = {.lex_state = 0},
  [52] = {.lex_state = 1},
  [53] = {.lex_state = 0},
  [54] = {.lex_state = 0},
  [55] = {.lex_state = 0},
  [56] = {.lex_state = 0},
  [57] = {.lex_state = 0},
  [58] = {.lex_state = 0},
  [59] = {.lex_state = 0},
  [60] = {.lex_state = 0},
  [61] = {.lex_state = 0},
  [62] = {.lex_state = 0},
  [63] = {.lex_state = 0},
  [64] = {.lex_state = 1},
  [65] = {.lex_state = 0},
  [66] = {.lex_state = 0},
  [67] = {.lex_state = 0},
  [68] = {.lex_state = 0},
  [69] = {.lex_state = 1},
  [70] = {.lex_state = 0},
  [71] = {.lex_state = 0},
  [72] = {.lex_state = 0},
  [73] = {.lex_state = 0},
  [74] = {.lex_state = 0},
  [75] = {.lex_state = 0},
  [76] = {.lex_state = 0},
  [77] = {.lex_state = 0},
  [78] = {.lex_state = 0},
  [79] = {.lex_state = 0},
  [80] = {.lex_state = 0},
  [81] = {.lex_state = 0},
  [82] = {.lex_state = 0},
  [83] = {.lex_state = 0},
  [84] = {.lex_state = 0},
  [85] = {.lex_state = 0},
  [86] = {.lex_state = 0},
  [87] = {.lex_state = 0},
  [88] = {.lex_state = 0},
  [89] = {.lex_state = 0},
  [90] = {.lex_state = 0},
  [91] = {.lex_state = 0},
  [92] = {.lex_state = 0},
  [93] = {.lex_state = 0},
  [94] = {.lex_state = 6},
  [95] = {.lex_state = 0},
  [96] = {.lex_state = 0},
  [97] = {.lex_state = 0},
  [98] = {.lex_state = 0},
  [99] = {.lex_state = 0},
  [100] = {.lex_state = 0},
  [101] = {.lex_state = 0},
  [102] = {.lex_state = 0},
  [103] = {.lex_state = 0},
  [104] = {.lex_state = 0},
  [105] = {.lex_state = 0},
  [106] = {.lex_state = 0},
  [107] = {.lex_state = 0},
  [108] = {.lex_state = 0},
  [109] = {.lex_state = 0},
  [110] = {.lex_state = 0},
  [111] = {.lex_state = 6},
  [112] = {.lex_state = 0},
  [113] = {.lex_state = 0},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
    [anon_sym_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
    [anon_sym_DOT] = ACTIONS(1),
    [anon_sym_EQ] = ACTIONS(1),
    [anon_sym_COLON] = ACTIONS(1),
    [anon_sym_LBRACK] = ACTIONS(1),
    [anon_sym_RBRACK] = ACTIONS(1),
    [anon_sym_AT] = ACTIONS(1),
    [anon_sym_LPAREN] = ACTIONS(1),
    [anon_sym_RPAREN] = ACTIONS(1),
    [aux_sym_tag_token1] = ACTIONS(1),
    [anon_sym_DQUOTE] = ACTIONS(1),
    [sym_escape_sequence] = ACTIONS(1),
    [sym_number] = ACTIONS(1),
    [aux_sym_comment_token1] = ACTIONS(1),
  },
  [1] = {
    [sym_document] = STATE(98),
    [sym__value] = STATE(96),
    [sym_top_level_struct] = STATE(96),
    [sym_struct] = STATE(96),
    [sym_map] = STATE(96),
    [sym_struct_field] = STATE(25),
    [sym_array] = STATE(96),
    [sym_tag_string] = STATE(96),
    [sym_string] = STATE(96),
    [sym_comment] = STATE(91),
    [aux_sym_comment_repeat1] = STATE(12),
    [ts_builtin_sym_end] = ACTIONS(3),
    [anon_sym_LBRACE] = ACTIONS(5),
    [anon_sym_DOT] = ACTIONS(7),
    [anon_sym_LBRACK] = ACTIONS(9),
    [anon_sym_AT] = ACTIONS(11),
    [anon_sym_DQUOTE] = ACTIONS(13),
    [sym_identifier] = ACTIONS(15),
    [sym_number] = ACTIONS(17),
    [sym_true] = ACTIONS(19),
    [sym_false] = ACTIONS(19),
    [sym_null] = ACTIONS(19),
    [aux_sym_comment_token1] = ACTIONS(21),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 13,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(23), 1,
      anon_sym_RBRACK,
    ACTIONS(25), 1,
      sym_number,
    STATE(6), 1,
      sym_comment,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(78), 1,
      sym_array_elem,
    ACTIONS(27), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(74), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [47] = 13,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(25), 1,
      sym_number,
    ACTIONS(29), 1,
      anon_sym_RBRACK,
    STATE(7), 1,
      sym_comment,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(22), 1,
      sym_array_elem,
    ACTIONS(27), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(74), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [94] = 13,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(25), 1,
      sym_number,
    ACTIONS(31), 1,
      anon_sym_RBRACK,
    STATE(8), 1,
      sym_comment,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(78), 1,
      sym_array_elem,
    ACTIONS(27), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(74), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [141] = 12,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(25), 1,
      sym_number,
    STATE(11), 1,
      sym_comment,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(78), 1,
      sym_array_elem,
    ACTIONS(27), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(74), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [185] = 9,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(31), 1,
      anon_sym_RBRACK,
    ACTIONS(33), 1,
      sym_number,
    ACTIONS(35), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(77), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [220] = 9,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(33), 1,
      sym_number,
    ACTIONS(37), 1,
      anon_sym_RBRACK,
    ACTIONS(35), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(77), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [255] = 9,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(33), 1,
      sym_number,
    ACTIONS(39), 1,
      anon_sym_RBRACK,
    ACTIONS(35), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(77), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [290] = 8,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(41), 1,
      sym_number,
    ACTIONS(43), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(81), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [322] = 8,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(45), 1,
      sym_number,
    ACTIONS(47), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(68), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [354] = 8,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(33), 1,
      sym_number,
    ACTIONS(35), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(77), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [386] = 4,
    ACTIONS(53), 1,
      aux_sym_comment_token1,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    ACTIONS(51), 4,
      sym_identifier,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(49), 9,
      ts_builtin_sym_end,
      anon_sym_LBRACE,
      anon_sym_RBRACE,
      anon_sym_DOT,
      anon_sym_LBRACK,
      anon_sym_RBRACK,
      anon_sym_AT,
      anon_sym_DQUOTE,
      sym_number,
  [410] = 8,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(55), 1,
      sym_number,
    ACTIONS(57), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(67), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [442] = 4,
    ACTIONS(63), 1,
      aux_sym_comment_token1,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    ACTIONS(61), 4,
      sym_identifier,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(59), 9,
      ts_builtin_sym_end,
      anon_sym_LBRACE,
      anon_sym_RBRACE,
      anon_sym_DOT,
      anon_sym_LBRACK,
      anon_sym_RBRACK,
      anon_sym_AT,
      anon_sym_DQUOTE,
      sym_number,
  [466] = 8,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_AT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      sym_identifier,
    ACTIONS(66), 1,
      sym_number,
    ACTIONS(68), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(76), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [498] = 9,
    ACTIONS(7), 1,
      anon_sym_DOT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(70), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(33), 1,
      sym_map_field,
    STATE(35), 1,
      sym_struct_field,
    STATE(66), 1,
      sym_comment,
    STATE(101), 1,
      sym_string,
  [526] = 7,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(72), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(73), 1,
      sym_comment,
    STATE(79), 1,
      sym_map_field,
    STATE(101), 1,
      sym_string,
  [548] = 1,
    ACTIONS(74), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
      aux_sym_comment_token1,
  [558] = 7,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(76), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(71), 1,
      sym_comment,
    STATE(79), 1,
      sym_map_field,
    STATE(101), 1,
      sym_string,
  [580] = 1,
    ACTIONS(78), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
      aux_sym_comment_token1,
  [590] = 6,
    ACTIONS(7), 1,
      anon_sym_DOT,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(80), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(63), 1,
      sym_struct_field,
    STATE(84), 1,
      sym_comment,
  [609] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(37), 1,
      anon_sym_RBRACK,
    ACTIONS(82), 1,
      anon_sym_COMMA,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(30), 1,
      aux_sym_array_repeat1,
    STATE(105), 1,
      sym_comment,
  [628] = 6,
    ACTIONS(7), 1,
      anon_sym_DOT,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(84), 1,
      ts_builtin_sym_end,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(63), 1,
      sym_struct_field,
    STATE(88), 1,
      sym_comment,
  [647] = 6,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(79), 1,
      sym_map_field,
    STATE(86), 1,
      sym_comment,
    STATE(101), 1,
      sym_string,
  [666] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(86), 1,
      ts_builtin_sym_end,
    ACTIONS(88), 1,
      anon_sym_COMMA,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(31), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(113), 1,
      sym_comment,
  [685] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(72), 1,
      anon_sym_RBRACE,
    ACTIONS(90), 1,
      anon_sym_COMMA,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(70), 1,
      aux_sym_map_repeat1,
    STATE(95), 1,
      sym_comment,
  [704] = 6,
    ACTIONS(7), 1,
      anon_sym_DOT,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(92), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(63), 1,
      sym_struct_field,
    STATE(89), 1,
      sym_comment,
  [723] = 6,
    ACTIONS(7), 1,
      anon_sym_DOT,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(94), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(32), 1,
      sym_struct_field,
    STATE(83), 1,
      sym_comment,
  [742] = 6,
    ACTIONS(7), 1,
      anon_sym_DOT,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(96), 1,
      ts_builtin_sym_end,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(63), 1,
      sym_struct_field,
    STATE(90), 1,
      sym_comment,
  [761] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(23), 1,
      anon_sym_RBRACK,
    ACTIONS(98), 1,
      anon_sym_COMMA,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(65), 1,
      aux_sym_array_repeat1,
    STATE(100), 1,
      sym_comment,
  [780] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(96), 1,
      ts_builtin_sym_end,
    ACTIONS(100), 1,
      anon_sym_COMMA,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(62), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(102), 1,
      sym_comment,
  [799] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(102), 1,
      anon_sym_COMMA,
    ACTIONS(104), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(38), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(112), 1,
      sym_comment,
  [818] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(106), 1,
      anon_sym_COMMA,
    ACTIONS(108), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(26), 1,
      aux_sym_map_repeat1,
    STATE(107), 1,
      sym_comment,
  [837] = 6,
    ACTIONS(7), 1,
      anon_sym_DOT,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(110), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(63), 1,
      sym_struct_field,
    STATE(85), 1,
      sym_comment,
  [856] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(112), 1,
      anon_sym_COMMA,
    ACTIONS(114), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(37), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(109), 1,
      sym_comment,
  [875] = 6,
    ACTIONS(7), 1,
      anon_sym_DOT,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(116), 1,
      anon_sym_RBRACE,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(63), 1,
      sym_struct_field,
    STATE(82), 1,
      sym_comment,
  [894] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(110), 1,
      anon_sym_RBRACE,
    ACTIONS(118), 1,
      anon_sym_COMMA,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(62), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(92), 1,
      sym_comment,
  [913] = 6,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    ACTIONS(116), 1,
      anon_sym_RBRACE,
    ACTIONS(120), 1,
      anon_sym_COMMA,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(62), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(104), 1,
      sym_comment,
  [932] = 1,
    ACTIONS(122), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [940] = 1,
    ACTIONS(124), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [948] = 1,
    ACTIONS(126), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [956] = 1,
    ACTIONS(128), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [964] = 1,
    ACTIONS(130), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [972] = 1,
    ACTIONS(132), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [980] = 1,
    ACTIONS(134), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [988] = 1,
    ACTIONS(136), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [996] = 1,
    ACTIONS(138), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1004] = 1,
    ACTIONS(140), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1012] = 1,
    ACTIONS(134), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1020] = 1,
    ACTIONS(142), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1028] = 1,
    ACTIONS(144), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1036] = 4,
    ACTIONS(146), 1,
      anon_sym_DQUOTE,
    STATE(69), 1,
      aux_sym_string_content_repeat1,
    STATE(110), 1,
      sym_string_content,
    ACTIONS(148), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [1050] = 1,
    ACTIONS(150), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1058] = 1,
    ACTIONS(152), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1066] = 1,
    ACTIONS(154), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1074] = 1,
    ACTIONS(156), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1082] = 1,
    ACTIONS(158), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1090] = 1,
    ACTIONS(160), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1098] = 1,
    ACTIONS(162), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1106] = 5,
    ACTIONS(7), 1,
      anon_sym_DOT,
    ACTIONS(21), 1,
      aux_sym_comment_token1,
    STATE(12), 1,
      aux_sym_comment_repeat1,
    STATE(63), 1,
      sym_struct_field,
    STATE(91), 1,
      sym_comment,
  [1122] = 1,
    ACTIONS(164), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1130] = 3,
    ACTIONS(168), 1,
      anon_sym_COMMA,
    STATE(62), 1,
      aux_sym_top_level_struct_repeat1,
    ACTIONS(166), 3,
      ts_builtin_sym_end,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1142] = 1,
    ACTIONS(166), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1149] = 3,
    ACTIONS(171), 1,
      anon_sym_DQUOTE,
    STATE(64), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(173), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [1160] = 3,
    ACTIONS(176), 1,
      anon_sym_COMMA,
    STATE(65), 1,
      aux_sym_array_repeat1,
    ACTIONS(179), 2,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1171] = 4,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(181), 1,
      anon_sym_RBRACE,
    ACTIONS(183), 1,
      anon_sym_DOT,
    STATE(106), 1,
      sym_string,
  [1184] = 1,
    ACTIONS(185), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1191] = 1,
    ACTIONS(187), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1198] = 3,
    ACTIONS(189), 1,
      anon_sym_DQUOTE,
    STATE(64), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(191), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [1209] = 3,
    ACTIONS(193), 1,
      anon_sym_COMMA,
    STATE(70), 1,
      aux_sym_map_repeat1,
    ACTIONS(196), 2,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1220] = 3,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(198), 1,
      anon_sym_RBRACE,
    STATE(106), 1,
      sym_string,
  [1230] = 3,
    ACTIONS(200), 1,
      anon_sym_LPAREN,
    ACTIONS(202), 1,
      aux_sym_tag_token1,
    STATE(80), 1,
      aux_sym_tag_repeat1,
  [1240] = 3,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(76), 1,
      anon_sym_RBRACE,
    STATE(106), 1,
      sym_string,
  [1250] = 1,
    ACTIONS(204), 3,
      anon_sym_COMMA,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1256] = 3,
    ACTIONS(206), 1,
      aux_sym_tag_token1,
    STATE(72), 1,
      aux_sym_tag_repeat1,
    STATE(97), 1,
      sym_tag,
  [1266] = 1,
    ACTIONS(208), 3,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1272] = 1,
    ACTIONS(210), 3,
      anon_sym_COMMA,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1278] = 1,
    ACTIONS(179), 3,
      anon_sym_COMMA,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1284] = 1,
    ACTIONS(196), 3,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1290] = 3,
    ACTIONS(212), 1,
      anon_sym_LPAREN,
    ACTIONS(214), 1,
      aux_sym_tag_token1,
    STATE(80), 1,
      aux_sym_tag_repeat1,
  [1300] = 1,
    ACTIONS(217), 3,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1306] = 2,
    ACTIONS(80), 1,
      anon_sym_RBRACE,
    ACTIONS(183), 1,
      anon_sym_DOT,
  [1313] = 2,
    ACTIONS(104), 1,
      anon_sym_RBRACE,
    ACTIONS(183), 1,
      anon_sym_DOT,
  [1320] = 2,
    ACTIONS(183), 1,
      anon_sym_DOT,
    ACTIONS(219), 1,
      anon_sym_RBRACE,
  [1327] = 2,
    ACTIONS(92), 1,
      anon_sym_RBRACE,
    ACTIONS(183), 1,
      anon_sym_DOT,
  [1334] = 2,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    STATE(106), 1,
      sym_string,
  [1341] = 2,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    STATE(93), 1,
      sym_string,
  [1348] = 2,
    ACTIONS(183), 1,
      anon_sym_DOT,
    ACTIONS(221), 1,
      ts_builtin_sym_end,
  [1355] = 2,
    ACTIONS(183), 1,
      anon_sym_DOT,
    ACTIONS(223), 1,
      anon_sym_RBRACE,
  [1362] = 2,
    ACTIONS(84), 1,
      ts_builtin_sym_end,
    ACTIONS(183), 1,
      anon_sym_DOT,
  [1369] = 1,
    ACTIONS(183), 1,
      anon_sym_DOT,
  [1373] = 1,
    ACTIONS(92), 1,
      anon_sym_RBRACE,
  [1377] = 1,
    ACTIONS(225), 1,
      anon_sym_RPAREN,
  [1381] = 1,
    ACTIONS(227), 1,
      sym_identifier,
  [1385] = 1,
    ACTIONS(76), 1,
      anon_sym_RBRACE,
  [1389] = 1,
    ACTIONS(229), 1,
      ts_builtin_sym_end,
  [1393] = 1,
    ACTIONS(231), 1,
      anon_sym_LPAREN,
  [1397] = 1,
    ACTIONS(233), 1,
      ts_builtin_sym_end,
  [1401] = 1,
    ACTIONS(235), 1,
      anon_sym_LBRACE,
  [1405] = 1,
    ACTIONS(31), 1,
      anon_sym_RBRACK,
  [1409] = 1,
    ACTIONS(237), 1,
      anon_sym_COLON,
  [1413] = 1,
    ACTIONS(84), 1,
      ts_builtin_sym_end,
  [1417] = 1,
    ACTIONS(239), 1,
      anon_sym_EQ,
  [1421] = 1,
    ACTIONS(80), 1,
      anon_sym_RBRACE,
  [1425] = 1,
    ACTIONS(23), 1,
      anon_sym_RBRACK,
  [1429] = 1,
    ACTIONS(241), 1,
      anon_sym_COLON,
  [1433] = 1,
    ACTIONS(72), 1,
      anon_sym_RBRACE,
  [1437] = 1,
    ACTIONS(243), 1,
      anon_sym_EQ,
  [1441] = 1,
    ACTIONS(110), 1,
      anon_sym_RBRACE,
  [1445] = 1,
    ACTIONS(245), 1,
      anon_sym_DQUOTE,
  [1449] = 1,
    ACTIONS(247), 1,
      sym_identifier,
  [1453] = 1,
    ACTIONS(116), 1,
      anon_sym_RBRACE,
  [1457] = 1,
    ACTIONS(96), 1,
      ts_builtin_sym_end,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(2)] = 0,
  [SMALL_STATE(3)] = 47,
  [SMALL_STATE(4)] = 94,
  [SMALL_STATE(5)] = 141,
  [SMALL_STATE(6)] = 185,
  [SMALL_STATE(7)] = 220,
  [SMALL_STATE(8)] = 255,
  [SMALL_STATE(9)] = 290,
  [SMALL_STATE(10)] = 322,
  [SMALL_STATE(11)] = 354,
  [SMALL_STATE(12)] = 386,
  [SMALL_STATE(13)] = 410,
  [SMALL_STATE(14)] = 442,
  [SMALL_STATE(15)] = 466,
  [SMALL_STATE(16)] = 498,
  [SMALL_STATE(17)] = 526,
  [SMALL_STATE(18)] = 548,
  [SMALL_STATE(19)] = 558,
  [SMALL_STATE(20)] = 580,
  [SMALL_STATE(21)] = 590,
  [SMALL_STATE(22)] = 609,
  [SMALL_STATE(23)] = 628,
  [SMALL_STATE(24)] = 647,
  [SMALL_STATE(25)] = 666,
  [SMALL_STATE(26)] = 685,
  [SMALL_STATE(27)] = 704,
  [SMALL_STATE(28)] = 723,
  [SMALL_STATE(29)] = 742,
  [SMALL_STATE(30)] = 761,
  [SMALL_STATE(31)] = 780,
  [SMALL_STATE(32)] = 799,
  [SMALL_STATE(33)] = 818,
  [SMALL_STATE(34)] = 837,
  [SMALL_STATE(35)] = 856,
  [SMALL_STATE(36)] = 875,
  [SMALL_STATE(37)] = 894,
  [SMALL_STATE(38)] = 913,
  [SMALL_STATE(39)] = 932,
  [SMALL_STATE(40)] = 940,
  [SMALL_STATE(41)] = 948,
  [SMALL_STATE(42)] = 956,
  [SMALL_STATE(43)] = 964,
  [SMALL_STATE(44)] = 972,
  [SMALL_STATE(45)] = 980,
  [SMALL_STATE(46)] = 988,
  [SMALL_STATE(47)] = 996,
  [SMALL_STATE(48)] = 1004,
  [SMALL_STATE(49)] = 1012,
  [SMALL_STATE(50)] = 1020,
  [SMALL_STATE(51)] = 1028,
  [SMALL_STATE(52)] = 1036,
  [SMALL_STATE(53)] = 1050,
  [SMALL_STATE(54)] = 1058,
  [SMALL_STATE(55)] = 1066,
  [SMALL_STATE(56)] = 1074,
  [SMALL_STATE(57)] = 1082,
  [SMALL_STATE(58)] = 1090,
  [SMALL_STATE(59)] = 1098,
  [SMALL_STATE(60)] = 1106,
  [SMALL_STATE(61)] = 1122,
  [SMALL_STATE(62)] = 1130,
  [SMALL_STATE(63)] = 1142,
  [SMALL_STATE(64)] = 1149,
  [SMALL_STATE(65)] = 1160,
  [SMALL_STATE(66)] = 1171,
  [SMALL_STATE(67)] = 1184,
  [SMALL_STATE(68)] = 1191,
  [SMALL_STATE(69)] = 1198,
  [SMALL_STATE(70)] = 1209,
  [SMALL_STATE(71)] = 1220,
  [SMALL_STATE(72)] = 1230,
  [SMALL_STATE(73)] = 1240,
  [SMALL_STATE(74)] = 1250,
  [SMALL_STATE(75)] = 1256,
  [SMALL_STATE(76)] = 1266,
  [SMALL_STATE(77)] = 1272,
  [SMALL_STATE(78)] = 1278,
  [SMALL_STATE(79)] = 1284,
  [SMALL_STATE(80)] = 1290,
  [SMALL_STATE(81)] = 1300,
  [SMALL_STATE(82)] = 1306,
  [SMALL_STATE(83)] = 1313,
  [SMALL_STATE(84)] = 1320,
  [SMALL_STATE(85)] = 1327,
  [SMALL_STATE(86)] = 1334,
  [SMALL_STATE(87)] = 1341,
  [SMALL_STATE(88)] = 1348,
  [SMALL_STATE(89)] = 1355,
  [SMALL_STATE(90)] = 1362,
  [SMALL_STATE(91)] = 1369,
  [SMALL_STATE(92)] = 1373,
  [SMALL_STATE(93)] = 1377,
  [SMALL_STATE(94)] = 1381,
  [SMALL_STATE(95)] = 1385,
  [SMALL_STATE(96)] = 1389,
  [SMALL_STATE(97)] = 1393,
  [SMALL_STATE(98)] = 1397,
  [SMALL_STATE(99)] = 1401,
  [SMALL_STATE(100)] = 1405,
  [SMALL_STATE(101)] = 1409,
  [SMALL_STATE(102)] = 1413,
  [SMALL_STATE(103)] = 1417,
  [SMALL_STATE(104)] = 1421,
  [SMALL_STATE(105)] = 1425,
  [SMALL_STATE(106)] = 1429,
  [SMALL_STATE(107)] = 1433,
  [SMALL_STATE(108)] = 1437,
  [SMALL_STATE(109)] = 1441,
  [SMALL_STATE(110)] = 1445,
  [SMALL_STATE(111)] = 1449,
  [SMALL_STATE(112)] = 1453,
  [SMALL_STATE(113)] = 1457,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 0),
  [5] = {.entry = {.count = 1, .reusable = true}}, SHIFT(16),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(94),
  [9] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [11] = {.entry = {.count = 1, .reusable = true}}, SHIFT(75),
  [13] = {.entry = {.count = 1, .reusable = true}}, SHIFT(52),
  [15] = {.entry = {.count = 1, .reusable = false}}, SHIFT(99),
  [17] = {.entry = {.count = 1, .reusable = true}}, SHIFT(96),
  [19] = {.entry = {.count = 1, .reusable = false}}, SHIFT(96),
  [21] = {.entry = {.count = 1, .reusable = true}}, SHIFT(12),
  [23] = {.entry = {.count = 1, .reusable = true}}, SHIFT(54),
  [25] = {.entry = {.count = 1, .reusable = true}}, SHIFT(74),
  [27] = {.entry = {.count = 1, .reusable = false}}, SHIFT(74),
  [29] = {.entry = {.count = 1, .reusable = true}}, SHIFT(42),
  [31] = {.entry = {.count = 1, .reusable = true}}, SHIFT(55),
  [33] = {.entry = {.count = 1, .reusable = true}}, SHIFT(77),
  [35] = {.entry = {.count = 1, .reusable = false}}, SHIFT(77),
  [37] = {.entry = {.count = 1, .reusable = true}}, SHIFT(51),
  [39] = {.entry = {.count = 1, .reusable = true}}, SHIFT(44),
  [41] = {.entry = {.count = 1, .reusable = true}}, SHIFT(81),
  [43] = {.entry = {.count = 1, .reusable = false}}, SHIFT(81),
  [45] = {.entry = {.count = 1, .reusable = true}}, SHIFT(68),
  [47] = {.entry = {.count = 1, .reusable = false}}, SHIFT(68),
  [49] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_comment, 1),
  [51] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_comment, 1),
  [53] = {.entry = {.count = 1, .reusable = true}}, SHIFT(14),
  [55] = {.entry = {.count = 1, .reusable = true}}, SHIFT(67),
  [57] = {.entry = {.count = 1, .reusable = false}}, SHIFT(67),
  [59] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_comment_repeat1, 2),
  [61] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_comment_repeat1, 2),
  [63] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_comment_repeat1, 2), SHIFT_REPEAT(14),
  [66] = {.entry = {.count = 1, .reusable = true}}, SHIFT(76),
  [68] = {.entry = {.count = 1, .reusable = false}}, SHIFT(76),
  [70] = {.entry = {.count = 1, .reusable = true}}, SHIFT(61),
  [72] = {.entry = {.count = 1, .reusable = true}}, SHIFT(50),
  [74] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 3),
  [76] = {.entry = {.count = 1, .reusable = true}}, SHIFT(57),
  [78] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 2),
  [80] = {.entry = {.count = 1, .reusable = true}}, SHIFT(43),
  [82] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [84] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 3),
  [86] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 1),
  [88] = {.entry = {.count = 1, .reusable = true}}, SHIFT(29),
  [90] = {.entry = {.count = 1, .reusable = true}}, SHIFT(19),
  [92] = {.entry = {.count = 1, .reusable = true}}, SHIFT(59),
  [94] = {.entry = {.count = 1, .reusable = true}}, SHIFT(39),
  [96] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 2),
  [98] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [100] = {.entry = {.count = 1, .reusable = true}}, SHIFT(23),
  [102] = {.entry = {.count = 1, .reusable = true}}, SHIFT(36),
  [104] = {.entry = {.count = 1, .reusable = true}}, SHIFT(58),
  [106] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [108] = {.entry = {.count = 1, .reusable = true}}, SHIFT(47),
  [110] = {.entry = {.count = 1, .reusable = true}}, SHIFT(56),
  [112] = {.entry = {.count = 1, .reusable = true}}, SHIFT(34),
  [114] = {.entry = {.count = 1, .reusable = true}}, SHIFT(45),
  [116] = {.entry = {.count = 1, .reusable = true}}, SHIFT(53),
  [118] = {.entry = {.count = 1, .reusable = true}}, SHIFT(27),
  [120] = {.entry = {.count = 1, .reusable = true}}, SHIFT(21),
  [122] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3, .production_id = 1),
  [124] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag_string, 5, .production_id = 4),
  [126] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 7, .production_id = 1),
  [128] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 2),
  [130] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6, .production_id = 1),
  [132] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 6),
  [134] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3),
  [136] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 6),
  [138] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 3),
  [140] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6),
  [142] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 4),
  [144] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [146] = {.entry = {.count = 1, .reusable = false}}, SHIFT(20),
  [148] = {.entry = {.count = 1, .reusable = true}}, SHIFT(69),
  [150] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5, .production_id = 1),
  [152] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 4),
  [154] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 5),
  [156] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4),
  [158] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 5),
  [160] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4, .production_id = 1),
  [162] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5),
  [164] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 2),
  [166] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2),
  [168] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2), SHIFT_REPEAT(60),
  [171] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_string_content_repeat1, 2),
  [173] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_string_content_repeat1, 2), SHIFT_REPEAT(64),
  [176] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2), SHIFT_REPEAT(5),
  [179] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2),
  [181] = {.entry = {.count = 1, .reusable = true}}, SHIFT(49),
  [183] = {.entry = {.count = 1, .reusable = true}}, SHIFT(111),
  [185] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 4, .production_id = 3),
  [187] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 5, .production_id = 5),
  [189] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_string_content, 1),
  [191] = {.entry = {.count = 1, .reusable = true}}, SHIFT(64),
  [193] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2), SHIFT_REPEAT(24),
  [196] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2),
  [198] = {.entry = {.count = 1, .reusable = true}}, SHIFT(46),
  [200] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 1),
  [202] = {.entry = {.count = 1, .reusable = true}}, SHIFT(80),
  [204] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array_elem, 1),
  [206] = {.entry = {.count = 1, .reusable = true}}, SHIFT(72),
  [208] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map_field, 3, .production_id = 2),
  [210] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array_elem, 2),
  [212] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2),
  [214] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2), SHIFT_REPEAT(80),
  [217] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map_field, 4, .production_id = 3),
  [219] = {.entry = {.count = 1, .reusable = true}}, SHIFT(41),
  [221] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 4),
  [223] = {.entry = {.count = 1, .reusable = true}}, SHIFT(48),
  [225] = {.entry = {.count = 1, .reusable = true}}, SHIFT(40),
  [227] = {.entry = {.count = 1, .reusable = true}}, SHIFT(103),
  [229] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 1),
  [231] = {.entry = {.count = 1, .reusable = true}}, SHIFT(87),
  [233] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [235] = {.entry = {.count = 1, .reusable = true}}, SHIFT(28),
  [237] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [239] = {.entry = {.count = 1, .reusable = true}}, SHIFT(13),
  [241] = {.entry = {.count = 1, .reusable = true}}, SHIFT(9),
  [243] = {.entry = {.count = 1, .reusable = true}}, SHIFT(10),
  [245] = {.entry = {.count = 1, .reusable = true}}, SHIFT(18),
  [247] = {.entry = {.count = 1, .reusable = true}}, SHIFT(108),
};

#ifdef __cplusplus
extern "C" {
#endif
#ifdef _WIN32
#define extern __declspec(dllexport)
#endif

extern const TSLanguage *tree_sitter_ziggy(void) {
  static const TSLanguage language = {
    .version = LANGUAGE_VERSION,
    .symbol_count = SYMBOL_COUNT,
    .alias_count = ALIAS_COUNT,
    .token_count = TOKEN_COUNT,
    .external_token_count = EXTERNAL_TOKEN_COUNT,
    .state_count = STATE_COUNT,
    .large_state_count = LARGE_STATE_COUNT,
    .production_id_count = PRODUCTION_ID_COUNT,
    .field_count = FIELD_COUNT,
    .max_alias_sequence_length = MAX_ALIAS_SEQUENCE_LENGTH,
    .parse_table = &ts_parse_table[0][0],
    .small_parse_table = ts_small_parse_table,
    .small_parse_table_map = ts_small_parse_table_map,
    .parse_actions = ts_parse_actions,
    .symbol_names = ts_symbol_names,
    .field_names = ts_field_names,
    .field_map_slices = ts_field_map_slices,
    .field_map_entries = ts_field_map_entries,
    .symbol_metadata = ts_symbol_metadata,
    .public_symbol_map = ts_symbol_map,
    .alias_map = ts_non_terminal_alias_map,
    .alias_sequences = &ts_alias_sequences[0][0],
    .lex_modes = ts_lex_modes,
    .lex_fn = ts_lex,
  };
  return &language;
}
#ifdef __cplusplus
}
#endif
