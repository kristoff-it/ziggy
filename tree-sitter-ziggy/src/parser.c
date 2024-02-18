#include <tree_sitter/parser.h>

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 13
#define STATE_COUNT 72
#define LARGE_STATE_COUNT 2
#define SYMBOL_COUNT 38
#define ALIAS_COUNT 0
#define TOKEN_COUNT 21
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 3
#define MAX_ALIAS_SEQUENCE_LENGTH 6
#define PRODUCTION_ID_COUNT 5

enum {
  anon_sym_COMMA = 1,
  anon_sym_LBRACE = 2,
  anon_sym_RBRACE = 3,
  anon_sym_LBRACK = 4,
  anon_sym_RBRACK = 5,
  anon_sym_DOT = 6,
  anon_sym_EQ = 7,
  sym_identifier = 8,
  anon_sym_COLON = 9,
  anon_sym_AT = 10,
  anon_sym_LPAREN = 11,
  anon_sym_RPAREN = 12,
  aux_sym_tag_token1 = 13,
  anon_sym_DQUOTE = 14,
  aux_sym_string_content_token1 = 15,
  sym_escape_sequence = 16,
  sym_number = 17,
  sym_true = 18,
  sym_false = 19,
  sym_null = 20,
  sym_document = 21,
  sym__value = 22,
  sym_top_level_struct = 23,
  sym_struct = 24,
  sym_map = 25,
  sym_array = 26,
  sym_struct_field = 27,
  sym_map_field = 28,
  sym_tag_string = 29,
  sym_tag = 30,
  sym_string = 31,
  sym_string_content = 32,
  aux_sym_top_level_struct_repeat1 = 33,
  aux_sym_map_repeat1 = 34,
  aux_sym_array_repeat1 = 35,
  aux_sym_tag_repeat1 = 36,
  aux_sym_string_content_repeat1 = 37,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [anon_sym_COMMA] = ",",
  [anon_sym_LBRACE] = "{",
  [anon_sym_RBRACE] = "}",
  [anon_sym_LBRACK] = "[",
  [anon_sym_RBRACK] = "]",
  [anon_sym_DOT] = ".",
  [anon_sym_EQ] = "=",
  [sym_identifier] = "identifier",
  [anon_sym_COLON] = ":",
  [anon_sym_AT] = "@",
  [anon_sym_LPAREN] = "(",
  [anon_sym_RPAREN] = ")",
  [aux_sym_tag_token1] = "tag_token1",
  [anon_sym_DQUOTE] = "\"",
  [aux_sym_string_content_token1] = "string_content_token1",
  [sym_escape_sequence] = "escape_sequence",
  [sym_number] = "number",
  [sym_true] = "true",
  [sym_false] = "false",
  [sym_null] = "null",
  [sym_document] = "document",
  [sym__value] = "_value",
  [sym_top_level_struct] = "top_level_struct",
  [sym_struct] = "struct",
  [sym_map] = "map",
  [sym_array] = "array",
  [sym_struct_field] = "struct_field",
  [sym_map_field] = "map_field",
  [sym_tag_string] = "tag_string",
  [sym_tag] = "tag",
  [sym_string] = "string",
  [sym_string_content] = "string_content",
  [aux_sym_top_level_struct_repeat1] = "top_level_struct_repeat1",
  [aux_sym_map_repeat1] = "map_repeat1",
  [aux_sym_array_repeat1] = "array_repeat1",
  [aux_sym_tag_repeat1] = "tag_repeat1",
  [aux_sym_string_content_repeat1] = "string_content_repeat1",
};

static const TSSymbol ts_symbol_map[] = {
  [ts_builtin_sym_end] = ts_builtin_sym_end,
  [anon_sym_COMMA] = anon_sym_COMMA,
  [anon_sym_LBRACE] = anon_sym_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
  [anon_sym_LBRACK] = anon_sym_LBRACK,
  [anon_sym_RBRACK] = anon_sym_RBRACK,
  [anon_sym_DOT] = anon_sym_DOT,
  [anon_sym_EQ] = anon_sym_EQ,
  [sym_identifier] = sym_identifier,
  [anon_sym_COLON] = anon_sym_COLON,
  [anon_sym_AT] = anon_sym_AT,
  [anon_sym_LPAREN] = anon_sym_LPAREN,
  [anon_sym_RPAREN] = anon_sym_RPAREN,
  [aux_sym_tag_token1] = aux_sym_tag_token1,
  [anon_sym_DQUOTE] = anon_sym_DQUOTE,
  [aux_sym_string_content_token1] = aux_sym_string_content_token1,
  [sym_escape_sequence] = sym_escape_sequence,
  [sym_number] = sym_number,
  [sym_true] = sym_true,
  [sym_false] = sym_false,
  [sym_null] = sym_null,
  [sym_document] = sym_document,
  [sym__value] = sym__value,
  [sym_top_level_struct] = sym_top_level_struct,
  [sym_struct] = sym_struct,
  [sym_map] = sym_map,
  [sym_array] = sym_array,
  [sym_struct_field] = sym_struct_field,
  [sym_map_field] = sym_map_field,
  [sym_tag_string] = sym_tag_string,
  [sym_tag] = sym_tag,
  [sym_string] = sym_string,
  [sym_string_content] = sym_string_content,
  [aux_sym_top_level_struct_repeat1] = aux_sym_top_level_struct_repeat1,
  [aux_sym_map_repeat1] = aux_sym_map_repeat1,
  [aux_sym_array_repeat1] = aux_sym_array_repeat1,
  [aux_sym_tag_repeat1] = aux_sym_tag_repeat1,
  [aux_sym_string_content_repeat1] = aux_sym_string_content_repeat1,
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
  [anon_sym_LBRACK] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_RBRACK] = {
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
  [sym_identifier] = {
    .visible = true,
    .named = true,
  },
  [anon_sym_COLON] = {
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
  [sym_array] = {
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
      if (lookahead == '"') ADVANCE(35);
      if (lookahead == '(') ADVANCE(32);
      if (lookahead == ')') ADVANCE(33);
      if (lookahead == ',') ADVANCE(12);
      if (lookahead == '-') ADVANCE(5);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '0') ADVANCE(39);
      if (lookahead == ':') ADVANCE(30);
      if (lookahead == '=') ADVANCE(18);
      if (lookahead == '@') ADVANCE(31);
      if (lookahead == '[') ADVANCE(15);
      if (lookahead == '\\') ADVANCE(7);
      if (lookahead == ']') ADVANCE(16);
      if (lookahead == '{') ADVANCE(13);
      if (lookahead == '}') ADVANCE(14);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(9)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(40);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 1:
      if (lookahead == '\n') SKIP(2)
      if (lookahead == '"') ADVANCE(35);
      if (lookahead == '\\') ADVANCE(7);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(36);
      if (lookahead != 0) ADVANCE(37);
      END_STATE();
    case 2:
      if (lookahead == '"') ADVANCE(35);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(2)
      END_STATE();
    case 3:
      if (lookahead == '(') ADVANCE(32);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(3)
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(34);
      END_STATE();
    case 4:
      if (lookahead == '-') ADVANCE(8);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(42);
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
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
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
          lookahead == 'u') ADVANCE(38);
      END_STATE();
    case 8:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(42);
      END_STATE();
    case 9:
      if (eof) ADVANCE(11);
      if (lookahead == '"') ADVANCE(35);
      if (lookahead == '(') ADVANCE(32);
      if (lookahead == ')') ADVANCE(33);
      if (lookahead == ',') ADVANCE(12);
      if (lookahead == '-') ADVANCE(5);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '0') ADVANCE(39);
      if (lookahead == ':') ADVANCE(30);
      if (lookahead == '=') ADVANCE(18);
      if (lookahead == '@') ADVANCE(31);
      if (lookahead == '[') ADVANCE(15);
      if (lookahead == ']') ADVANCE(16);
      if (lookahead == '{') ADVANCE(13);
      if (lookahead == '}') ADVANCE(14);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(9)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(40);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 10:
      if (eof) ADVANCE(11);
      if (lookahead == '"') ADVANCE(35);
      if (lookahead == '-') ADVANCE(5);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '0') ADVANCE(39);
      if (lookahead == '@') ADVANCE(31);
      if (lookahead == '[') ADVANCE(15);
      if (lookahead == ']') ADVANCE(16);
      if (lookahead == 'f') ADVANCE(19);
      if (lookahead == 'n') ADVANCE(28);
      if (lookahead == 't') ADVANCE(25);
      if (lookahead == '{') ADVANCE(13);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(10)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(40);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
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
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 16:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 17:
      ACCEPT_TOKEN(anon_sym_DOT);
      END_STATE();
    case 18:
      ACCEPT_TOKEN(anon_sym_EQ);
      END_STATE();
    case 19:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'a') ADVANCE(22);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('b' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'e') ADVANCE(43);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 21:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'e') ADVANCE(44);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 22:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'l') ADVANCE(26);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 23:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'l') ADVANCE(45);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'l') ADVANCE(23);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 25:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'r') ADVANCE(27);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 26:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 's') ADVANCE(21);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 27:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'u') ADVANCE(20);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 28:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'u') ADVANCE(24);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 29:
      ACCEPT_TOKEN(sym_identifier);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 30:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 31:
      ACCEPT_TOKEN(anon_sym_AT);
      END_STATE();
    case 32:
      ACCEPT_TOKEN(anon_sym_LPAREN);
      END_STATE();
    case 33:
      ACCEPT_TOKEN(anon_sym_RPAREN);
      END_STATE();
    case 34:
      ACCEPT_TOKEN(aux_sym_tag_token1);
      END_STATE();
    case 35:
      ACCEPT_TOKEN(anon_sym_DQUOTE);
      END_STATE();
    case 36:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(36);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(37);
      END_STATE();
    case 37:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(37);
      END_STATE();
    case 38:
      ACCEPT_TOKEN(sym_escape_sequence);
      END_STATE();
    case 39:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(41);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      END_STATE();
    case 40:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(41);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(40);
      END_STATE();
    case 41:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
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
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 44:
      ACCEPT_TOKEN(sym_false);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
      END_STATE();
    case 45:
      ACCEPT_TOKEN(sym_null);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(29);
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
  [8] = {.lex_state = 0},
  [9] = {.lex_state = 0},
  [10] = {.lex_state = 0},
  [11] = {.lex_state = 1},
  [12] = {.lex_state = 0},
  [13] = {.lex_state = 0},
  [14] = {.lex_state = 0},
  [15] = {.lex_state = 0},
  [16] = {.lex_state = 0},
  [17] = {.lex_state = 0},
  [18] = {.lex_state = 0},
  [19] = {.lex_state = 0},
  [20] = {.lex_state = 0},
  [21] = {.lex_state = 0},
  [22] = {.lex_state = 0},
  [23] = {.lex_state = 1},
  [24] = {.lex_state = 0},
  [25] = {.lex_state = 0},
  [26] = {.lex_state = 0},
  [27] = {.lex_state = 0},
  [28] = {.lex_state = 0},
  [29] = {.lex_state = 0},
  [30] = {.lex_state = 0},
  [31] = {.lex_state = 1},
  [32] = {.lex_state = 0},
  [33] = {.lex_state = 0},
  [34] = {.lex_state = 3},
  [35] = {.lex_state = 0},
  [36] = {.lex_state = 0},
  [37] = {.lex_state = 3},
  [38] = {.lex_state = 0},
  [39] = {.lex_state = 0},
  [40] = {.lex_state = 0},
  [41] = {.lex_state = 0},
  [42] = {.lex_state = 0},
  [43] = {.lex_state = 0},
  [44] = {.lex_state = 0},
  [45] = {.lex_state = 0},
  [46] = {.lex_state = 0},
  [47] = {.lex_state = 3},
  [48] = {.lex_state = 0},
  [49] = {.lex_state = 0},
  [50] = {.lex_state = 0},
  [51] = {.lex_state = 0},
  [52] = {.lex_state = 0},
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
  [64] = {.lex_state = 0},
  [65] = {.lex_state = 0},
  [66] = {.lex_state = 0},
  [67] = {.lex_state = 0},
  [68] = {.lex_state = 0},
  [69] = {.lex_state = 6},
  [70] = {.lex_state = 0},
  [71] = {.lex_state = 0},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
    [anon_sym_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
    [anon_sym_LBRACK] = ACTIONS(1),
    [anon_sym_RBRACK] = ACTIONS(1),
    [anon_sym_DOT] = ACTIONS(1),
    [anon_sym_EQ] = ACTIONS(1),
    [sym_identifier] = ACTIONS(1),
    [anon_sym_COLON] = ACTIONS(1),
    [anon_sym_AT] = ACTIONS(1),
    [anon_sym_LPAREN] = ACTIONS(1),
    [anon_sym_RPAREN] = ACTIONS(1),
    [aux_sym_tag_token1] = ACTIONS(1),
    [anon_sym_DQUOTE] = ACTIONS(1),
    [sym_escape_sequence] = ACTIONS(1),
    [sym_number] = ACTIONS(1),
  },
  [1] = {
    [sym_document] = STATE(65),
    [sym_top_level_struct] = STATE(63),
    [sym_struct] = STATE(63),
    [sym_map] = STATE(63),
    [sym_array] = STATE(63),
    [sym_struct_field] = STATE(41),
    [sym_string] = STATE(63),
    [ts_builtin_sym_end] = ACTIONS(3),
    [anon_sym_LBRACE] = ACTIONS(5),
    [anon_sym_LBRACK] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(9),
    [sym_identifier] = ACTIONS(11),
    [anon_sym_DQUOTE] = ACTIONS(13),
    [sym_number] = ACTIONS(15),
    [sym_true] = ACTIONS(17),
    [sym_false] = ACTIONS(17),
    [sym_null] = ACTIONS(17),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 9,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_RBRACK,
    ACTIONS(21), 1,
      anon_sym_AT,
    ACTIONS(23), 1,
      sym_number,
    ACTIONS(25), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(58), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [35] = 9,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_AT,
    ACTIONS(27), 1,
      anon_sym_RBRACK,
    ACTIONS(29), 1,
      sym_number,
    ACTIONS(31), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(50), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [70] = 9,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_AT,
    ACTIONS(23), 1,
      sym_number,
    ACTIONS(33), 1,
      anon_sym_RBRACK,
    ACTIONS(25), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(58), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [105] = 8,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_AT,
    ACTIONS(23), 1,
      sym_number,
    ACTIONS(25), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(58), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [137] = 8,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_AT,
    ACTIONS(35), 1,
      sym_number,
    ACTIONS(37), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(57), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [169] = 8,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_AT,
    ACTIONS(39), 1,
      sym_number,
    ACTIONS(41), 3,
      sym_true,
      sym_false,
      sym_null,
    STATE(61), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [201] = 6,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(43), 1,
      anon_sym_RBRACE,
    STATE(36), 1,
      sym_map_field,
    STATE(43), 1,
      sym_struct_field,
    STATE(70), 1,
      sym_string,
  [220] = 1,
    ACTIONS(45), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_COLON,
      anon_sym_RPAREN,
  [229] = 1,
    ACTIONS(47), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_COLON,
      anon_sym_RPAREN,
  [238] = 4,
    ACTIONS(49), 1,
      anon_sym_DQUOTE,
    STATE(23), 1,
      aux_sym_string_content_repeat1,
    STATE(64), 1,
      sym_string_content,
    ACTIONS(51), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [252] = 1,
    ACTIONS(53), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [259] = 1,
    ACTIONS(55), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [266] = 1,
    ACTIONS(57), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [273] = 1,
    ACTIONS(59), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [280] = 1,
    ACTIONS(61), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [287] = 1,
    ACTIONS(63), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [294] = 1,
    ACTIONS(65), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [301] = 1,
    ACTIONS(67), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [308] = 1,
    ACTIONS(69), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [315] = 1,
    ACTIONS(71), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [322] = 4,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(73), 1,
      anon_sym_RBRACE,
    STATE(62), 1,
      sym_map_field,
    STATE(70), 1,
      sym_string,
  [335] = 3,
    ACTIONS(75), 1,
      anon_sym_DQUOTE,
    STATE(31), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(77), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [346] = 1,
    ACTIONS(79), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [353] = 1,
    ACTIONS(81), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [360] = 3,
    ACTIONS(85), 1,
      anon_sym_COMMA,
    STATE(26), 1,
      aux_sym_top_level_struct_repeat1,
    ACTIONS(83), 2,
      ts_builtin_sym_end,
      anon_sym_RBRACE,
  [371] = 1,
    ACTIONS(88), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [378] = 1,
    ACTIONS(90), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [385] = 4,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(92), 1,
      anon_sym_RBRACE,
    STATE(62), 1,
      sym_map_field,
    STATE(70), 1,
      sym_string,
  [398] = 1,
    ACTIONS(94), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [405] = 3,
    ACTIONS(96), 1,
      anon_sym_DQUOTE,
    STATE(31), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(98), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [416] = 1,
    ACTIONS(101), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [423] = 1,
    ACTIONS(83), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [429] = 3,
    ACTIONS(103), 1,
      anon_sym_LPAREN,
    ACTIONS(105), 1,
      aux_sym_tag_token1,
    STATE(34), 1,
      aux_sym_tag_repeat1,
  [439] = 3,
    ACTIONS(92), 1,
      anon_sym_RBRACE,
    ACTIONS(108), 1,
      anon_sym_COMMA,
    STATE(49), 1,
      aux_sym_map_repeat1,
  [449] = 3,
    ACTIONS(110), 1,
      anon_sym_COMMA,
    ACTIONS(112), 1,
      anon_sym_RBRACE,
    STATE(35), 1,
      aux_sym_map_repeat1,
  [459] = 3,
    ACTIONS(114), 1,
      anon_sym_LPAREN,
    ACTIONS(116), 1,
      aux_sym_tag_token1,
    STATE(34), 1,
      aux_sym_tag_repeat1,
  [469] = 3,
    ACTIONS(19), 1,
      anon_sym_RBRACK,
    ACTIONS(118), 1,
      anon_sym_COMMA,
    STATE(56), 1,
      aux_sym_array_repeat1,
  [479] = 3,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(120), 1,
      anon_sym_RBRACE,
    STATE(33), 1,
      sym_struct_field,
  [489] = 3,
    ACTIONS(122), 1,
      anon_sym_COMMA,
    ACTIONS(124), 1,
      anon_sym_RBRACE,
    STATE(54), 1,
      aux_sym_top_level_struct_repeat1,
  [499] = 3,
    ACTIONS(126), 1,
      ts_builtin_sym_end,
    ACTIONS(128), 1,
      anon_sym_COMMA,
    STATE(46), 1,
      aux_sym_top_level_struct_repeat1,
  [509] = 3,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(130), 1,
      ts_builtin_sym_end,
    STATE(33), 1,
      sym_struct_field,
  [519] = 3,
    ACTIONS(132), 1,
      anon_sym_COMMA,
    ACTIONS(134), 1,
      anon_sym_RBRACE,
    STATE(52), 1,
      aux_sym_top_level_struct_repeat1,
  [529] = 3,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(136), 1,
      anon_sym_RBRACE,
    STATE(33), 1,
      sym_struct_field,
  [539] = 3,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(138), 1,
      anon_sym_RBRACE,
    STATE(33), 1,
      sym_struct_field,
  [549] = 3,
    ACTIONS(140), 1,
      ts_builtin_sym_end,
    ACTIONS(142), 1,
      anon_sym_COMMA,
    STATE(26), 1,
      aux_sym_top_level_struct_repeat1,
  [559] = 3,
    ACTIONS(144), 1,
      aux_sym_tag_token1,
    STATE(37), 1,
      aux_sym_tag_repeat1,
    STATE(71), 1,
      sym_tag,
  [569] = 3,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(140), 1,
      ts_builtin_sym_end,
    STATE(33), 1,
      sym_struct_field,
  [579] = 3,
    ACTIONS(146), 1,
      anon_sym_COMMA,
    ACTIONS(149), 1,
      anon_sym_RBRACE,
    STATE(49), 1,
      aux_sym_map_repeat1,
  [589] = 3,
    ACTIONS(151), 1,
      anon_sym_COMMA,
    ACTIONS(153), 1,
      anon_sym_RBRACK,
    STATE(38), 1,
      aux_sym_array_repeat1,
  [599] = 3,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    STATE(62), 1,
      sym_map_field,
    STATE(70), 1,
      sym_string,
  [609] = 3,
    ACTIONS(136), 1,
      anon_sym_RBRACE,
    ACTIONS(155), 1,
      anon_sym_COMMA,
    STATE(26), 1,
      aux_sym_top_level_struct_repeat1,
  [619] = 3,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(157), 1,
      anon_sym_RBRACE,
    STATE(40), 1,
      sym_struct_field,
  [629] = 3,
    ACTIONS(159), 1,
      anon_sym_COMMA,
    ACTIONS(161), 1,
      anon_sym_RBRACE,
    STATE(26), 1,
      aux_sym_top_level_struct_repeat1,
  [639] = 3,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(161), 1,
      anon_sym_RBRACE,
    STATE(33), 1,
      sym_struct_field,
  [649] = 3,
    ACTIONS(163), 1,
      anon_sym_COMMA,
    ACTIONS(166), 1,
      anon_sym_RBRACK,
    STATE(56), 1,
      aux_sym_array_repeat1,
  [659] = 1,
    ACTIONS(168), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [665] = 1,
    ACTIONS(166), 2,
      anon_sym_COMMA,
      anon_sym_RBRACK,
  [670] = 2,
    ACTIONS(9), 1,
      anon_sym_DOT,
    STATE(33), 1,
      sym_struct_field,
  [677] = 2,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    STATE(67), 1,
      sym_string,
  [684] = 1,
    ACTIONS(170), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [689] = 1,
    ACTIONS(149), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [694] = 1,
    ACTIONS(172), 1,
      ts_builtin_sym_end,
  [698] = 1,
    ACTIONS(174), 1,
      anon_sym_DQUOTE,
  [702] = 1,
    ACTIONS(176), 1,
      ts_builtin_sym_end,
  [706] = 1,
    ACTIONS(178), 1,
      anon_sym_EQ,
  [710] = 1,
    ACTIONS(180), 1,
      anon_sym_RPAREN,
  [714] = 1,
    ACTIONS(182), 1,
      anon_sym_LBRACE,
  [718] = 1,
    ACTIONS(184), 1,
      sym_identifier,
  [722] = 1,
    ACTIONS(186), 1,
      anon_sym_COLON,
  [726] = 1,
    ACTIONS(188), 1,
      anon_sym_LPAREN,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(2)] = 0,
  [SMALL_STATE(3)] = 35,
  [SMALL_STATE(4)] = 70,
  [SMALL_STATE(5)] = 105,
  [SMALL_STATE(6)] = 137,
  [SMALL_STATE(7)] = 169,
  [SMALL_STATE(8)] = 201,
  [SMALL_STATE(9)] = 220,
  [SMALL_STATE(10)] = 229,
  [SMALL_STATE(11)] = 238,
  [SMALL_STATE(12)] = 252,
  [SMALL_STATE(13)] = 259,
  [SMALL_STATE(14)] = 266,
  [SMALL_STATE(15)] = 273,
  [SMALL_STATE(16)] = 280,
  [SMALL_STATE(17)] = 287,
  [SMALL_STATE(18)] = 294,
  [SMALL_STATE(19)] = 301,
  [SMALL_STATE(20)] = 308,
  [SMALL_STATE(21)] = 315,
  [SMALL_STATE(22)] = 322,
  [SMALL_STATE(23)] = 335,
  [SMALL_STATE(24)] = 346,
  [SMALL_STATE(25)] = 353,
  [SMALL_STATE(26)] = 360,
  [SMALL_STATE(27)] = 371,
  [SMALL_STATE(28)] = 378,
  [SMALL_STATE(29)] = 385,
  [SMALL_STATE(30)] = 398,
  [SMALL_STATE(31)] = 405,
  [SMALL_STATE(32)] = 416,
  [SMALL_STATE(33)] = 423,
  [SMALL_STATE(34)] = 429,
  [SMALL_STATE(35)] = 439,
  [SMALL_STATE(36)] = 449,
  [SMALL_STATE(37)] = 459,
  [SMALL_STATE(38)] = 469,
  [SMALL_STATE(39)] = 479,
  [SMALL_STATE(40)] = 489,
  [SMALL_STATE(41)] = 499,
  [SMALL_STATE(42)] = 509,
  [SMALL_STATE(43)] = 519,
  [SMALL_STATE(44)] = 529,
  [SMALL_STATE(45)] = 539,
  [SMALL_STATE(46)] = 549,
  [SMALL_STATE(47)] = 559,
  [SMALL_STATE(48)] = 569,
  [SMALL_STATE(49)] = 579,
  [SMALL_STATE(50)] = 589,
  [SMALL_STATE(51)] = 599,
  [SMALL_STATE(52)] = 609,
  [SMALL_STATE(53)] = 619,
  [SMALL_STATE(54)] = 629,
  [SMALL_STATE(55)] = 639,
  [SMALL_STATE(56)] = 649,
  [SMALL_STATE(57)] = 659,
  [SMALL_STATE(58)] = 665,
  [SMALL_STATE(59)] = 670,
  [SMALL_STATE(60)] = 677,
  [SMALL_STATE(61)] = 684,
  [SMALL_STATE(62)] = 689,
  [SMALL_STATE(63)] = 694,
  [SMALL_STATE(64)] = 698,
  [SMALL_STATE(65)] = 702,
  [SMALL_STATE(66)] = 706,
  [SMALL_STATE(67)] = 710,
  [SMALL_STATE(68)] = 714,
  [SMALL_STATE(69)] = 718,
  [SMALL_STATE(70)] = 722,
  [SMALL_STATE(71)] = 726,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 0),
  [5] = {.entry = {.count = 1, .reusable = true}}, SHIFT(8),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [9] = {.entry = {.count = 1, .reusable = true}}, SHIFT(69),
  [11] = {.entry = {.count = 1, .reusable = false}}, SHIFT(68),
  [13] = {.entry = {.count = 1, .reusable = true}}, SHIFT(11),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(63),
  [17] = {.entry = {.count = 1, .reusable = false}}, SHIFT(63),
  [19] = {.entry = {.count = 1, .reusable = true}}, SHIFT(12),
  [21] = {.entry = {.count = 1, .reusable = true}}, SHIFT(47),
  [23] = {.entry = {.count = 1, .reusable = true}}, SHIFT(58),
  [25] = {.entry = {.count = 1, .reusable = false}}, SHIFT(58),
  [27] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [29] = {.entry = {.count = 1, .reusable = true}}, SHIFT(50),
  [31] = {.entry = {.count = 1, .reusable = false}}, SHIFT(50),
  [33] = {.entry = {.count = 1, .reusable = true}}, SHIFT(18),
  [35] = {.entry = {.count = 1, .reusable = true}}, SHIFT(57),
  [37] = {.entry = {.count = 1, .reusable = false}}, SHIFT(57),
  [39] = {.entry = {.count = 1, .reusable = true}}, SHIFT(61),
  [41] = {.entry = {.count = 1, .reusable = false}}, SHIFT(61),
  [43] = {.entry = {.count = 1, .reusable = true}}, SHIFT(32),
  [45] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 3),
  [47] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 2),
  [49] = {.entry = {.count = 1, .reusable = false}}, SHIFT(10),
  [51] = {.entry = {.count = 1, .reusable = true}}, SHIFT(23),
  [53] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 4),
  [55] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3, .production_id = 1),
  [57] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6, .production_id = 1),
  [59] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag_string, 5, .production_id = 4),
  [61] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5, .production_id = 1),
  [63] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 2),
  [65] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 5),
  [67] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 5),
  [69] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5),
  [71] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4, .production_id = 1),
  [73] = {.entry = {.count = 1, .reusable = true}}, SHIFT(19),
  [75] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_string_content, 1),
  [77] = {.entry = {.count = 1, .reusable = true}}, SHIFT(31),
  [79] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 4),
  [81] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4),
  [83] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2),
  [85] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2), SHIFT_REPEAT(59),
  [88] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3),
  [90] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [92] = {.entry = {.count = 1, .reusable = true}}, SHIFT(24),
  [94] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 3),
  [96] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_string_content_repeat1, 2),
  [98] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_string_content_repeat1, 2), SHIFT_REPEAT(31),
  [101] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 2),
  [103] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2),
  [105] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2), SHIFT_REPEAT(34),
  [108] = {.entry = {.count = 1, .reusable = true}}, SHIFT(22),
  [110] = {.entry = {.count = 1, .reusable = true}}, SHIFT(29),
  [112] = {.entry = {.count = 1, .reusable = true}}, SHIFT(30),
  [114] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 1),
  [116] = {.entry = {.count = 1, .reusable = true}}, SHIFT(34),
  [118] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [120] = {.entry = {.count = 1, .reusable = true}}, SHIFT(14),
  [122] = {.entry = {.count = 1, .reusable = true}}, SHIFT(55),
  [124] = {.entry = {.count = 1, .reusable = true}}, SHIFT(21),
  [126] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 1),
  [128] = {.entry = {.count = 1, .reusable = true}}, SHIFT(48),
  [130] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 3),
  [132] = {.entry = {.count = 1, .reusable = true}}, SHIFT(44),
  [134] = {.entry = {.count = 1, .reusable = true}}, SHIFT(27),
  [136] = {.entry = {.count = 1, .reusable = true}}, SHIFT(25),
  [138] = {.entry = {.count = 1, .reusable = true}}, SHIFT(20),
  [140] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 2),
  [142] = {.entry = {.count = 1, .reusable = true}}, SHIFT(42),
  [144] = {.entry = {.count = 1, .reusable = true}}, SHIFT(37),
  [146] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2), SHIFT_REPEAT(51),
  [149] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2),
  [151] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [153] = {.entry = {.count = 1, .reusable = true}}, SHIFT(28),
  [155] = {.entry = {.count = 1, .reusable = true}}, SHIFT(45),
  [157] = {.entry = {.count = 1, .reusable = true}}, SHIFT(13),
  [159] = {.entry = {.count = 1, .reusable = true}}, SHIFT(39),
  [161] = {.entry = {.count = 1, .reusable = true}}, SHIFT(16),
  [163] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2), SHIFT_REPEAT(5),
  [166] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2),
  [168] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 4, .production_id = 3),
  [170] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map_field, 3, .production_id = 2),
  [172] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 1),
  [174] = {.entry = {.count = 1, .reusable = true}}, SHIFT(9),
  [176] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [178] = {.entry = {.count = 1, .reusable = true}}, SHIFT(6),
  [180] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [182] = {.entry = {.count = 1, .reusable = true}}, SHIFT(53),
  [184] = {.entry = {.count = 1, .reusable = true}}, SHIFT(66),
  [186] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [188] = {.entry = {.count = 1, .reusable = true}}, SHIFT(60),
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
