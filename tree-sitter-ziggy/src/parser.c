#include <tree_sitter/parser.h>

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 13
#define STATE_COUNT 72
#define LARGE_STATE_COUNT 2
#define SYMBOL_COUNT 39
#define ALIAS_COUNT 0
#define TOKEN_COUNT 22
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
  sym_comment = 21,
  sym_document = 22,
  sym__value = 23,
  sym_top_level_struct = 24,
  sym_struct = 25,
  sym_map = 26,
  sym_array = 27,
  sym_struct_field = 28,
  sym_map_field = 29,
  sym_tag_string = 30,
  sym_tag = 31,
  sym_string = 32,
  sym_string_content = 33,
  aux_sym_top_level_struct_repeat1 = 34,
  aux_sym_map_repeat1 = 35,
  aux_sym_array_repeat1 = 36,
  aux_sym_tag_repeat1 = 37,
  aux_sym_string_content_repeat1 = 38,
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
  [sym_comment] = "comment",
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
  [sym_comment] = sym_comment,
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
  [sym_comment] = {
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
      if (eof) ADVANCE(12);
      if (lookahead == '"') ADVANCE(36);
      if (lookahead == '(') ADVANCE(33);
      if (lookahead == ')') ADVANCE(34);
      if (lookahead == ',') ADVANCE(13);
      if (lookahead == '-') ADVANCE(7);
      if (lookahead == '.') ADVANCE(18);
      if (lookahead == '/') ADVANCE(6);
      if (lookahead == '0') ADVANCE(41);
      if (lookahead == ':') ADVANCE(31);
      if (lookahead == '=') ADVANCE(19);
      if (lookahead == '@') ADVANCE(32);
      if (lookahead == '[') ADVANCE(16);
      if (lookahead == '\\') ADVANCE(8);
      if (lookahead == ']') ADVANCE(17);
      if (lookahead == '{') ADVANCE(14);
      if (lookahead == '}') ADVANCE(15);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(10)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(42);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 1:
      if (lookahead == '\n') SKIP(2)
      if (lookahead == '"') ADVANCE(36);
      if (lookahead == '/') ADVANCE(38);
      if (lookahead == '\\') ADVANCE(8);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(37);
      if (lookahead != 0) ADVANCE(39);
      END_STATE();
    case 2:
      if (lookahead == '"') ADVANCE(36);
      if (lookahead == '/') ADVANCE(6);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(2)
      END_STATE();
    case 3:
      if (lookahead == '(') ADVANCE(33);
      if (lookahead == '/') ADVANCE(6);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(3)
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(35);
      END_STATE();
    case 4:
      if (lookahead == '-') ADVANCE(9);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(44);
      END_STATE();
    case 5:
      if (lookahead == '/') ADVANCE(6);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(5)
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 6:
      if (lookahead == '/') ADVANCE(48);
      END_STATE();
    case 7:
      if (lookahead == '0') ADVANCE(41);
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(42);
      END_STATE();
    case 8:
      if (lookahead == '"' ||
          lookahead == '/' ||
          lookahead == '\\' ||
          lookahead == 'b' ||
          lookahead == 'f' ||
          lookahead == 'n' ||
          lookahead == 'r' ||
          lookahead == 't' ||
          lookahead == 'u') ADVANCE(40);
      END_STATE();
    case 9:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(44);
      END_STATE();
    case 10:
      if (eof) ADVANCE(12);
      if (lookahead == '"') ADVANCE(36);
      if (lookahead == '(') ADVANCE(33);
      if (lookahead == ')') ADVANCE(34);
      if (lookahead == ',') ADVANCE(13);
      if (lookahead == '-') ADVANCE(7);
      if (lookahead == '.') ADVANCE(18);
      if (lookahead == '/') ADVANCE(6);
      if (lookahead == '0') ADVANCE(41);
      if (lookahead == ':') ADVANCE(31);
      if (lookahead == '=') ADVANCE(19);
      if (lookahead == '@') ADVANCE(32);
      if (lookahead == '[') ADVANCE(16);
      if (lookahead == ']') ADVANCE(17);
      if (lookahead == '{') ADVANCE(14);
      if (lookahead == '}') ADVANCE(15);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(10)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(42);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 11:
      if (eof) ADVANCE(12);
      if (lookahead == '"') ADVANCE(36);
      if (lookahead == '-') ADVANCE(7);
      if (lookahead == '.') ADVANCE(18);
      if (lookahead == '/') ADVANCE(6);
      if (lookahead == '0') ADVANCE(41);
      if (lookahead == '@') ADVANCE(32);
      if (lookahead == '[') ADVANCE(16);
      if (lookahead == ']') ADVANCE(17);
      if (lookahead == 'f') ADVANCE(20);
      if (lookahead == 'n') ADVANCE(29);
      if (lookahead == 't') ADVANCE(26);
      if (lookahead == '{') ADVANCE(14);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(11)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(42);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 12:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 13:
      ACCEPT_TOKEN(anon_sym_COMMA);
      END_STATE();
    case 14:
      ACCEPT_TOKEN(anon_sym_LBRACE);
      END_STATE();
    case 15:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 16:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 17:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 18:
      ACCEPT_TOKEN(anon_sym_DOT);
      END_STATE();
    case 19:
      ACCEPT_TOKEN(anon_sym_EQ);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'a') ADVANCE(23);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('b' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 21:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'e') ADVANCE(45);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 22:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'e') ADVANCE(46);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 23:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'l') ADVANCE(27);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'l') ADVANCE(47);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 25:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'l') ADVANCE(24);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 26:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'r') ADVANCE(28);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 27:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 's') ADVANCE(22);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 28:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'u') ADVANCE(21);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 29:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == 'u') ADVANCE(25);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 30:
      ACCEPT_TOKEN(sym_identifier);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 31:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 32:
      ACCEPT_TOKEN(anon_sym_AT);
      END_STATE();
    case 33:
      ACCEPT_TOKEN(anon_sym_LPAREN);
      END_STATE();
    case 34:
      ACCEPT_TOKEN(anon_sym_RPAREN);
      END_STATE();
    case 35:
      ACCEPT_TOKEN(aux_sym_tag_token1);
      END_STATE();
    case 36:
      ACCEPT_TOKEN(anon_sym_DQUOTE);
      END_STATE();
    case 37:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead == '/') ADVANCE(38);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(37);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(39);
      END_STATE();
    case 38:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead == '/') ADVANCE(39);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(39);
      END_STATE();
    case 39:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(39);
      END_STATE();
    case 40:
      ACCEPT_TOKEN(sym_escape_sequence);
      END_STATE();
    case 41:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(43);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      END_STATE();
    case 42:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(43);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(42);
      END_STATE();
    case 43:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(43);
      END_STATE();
    case 44:
      ACCEPT_TOKEN(sym_number);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(44);
      END_STATE();
    case 45:
      ACCEPT_TOKEN(sym_true);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 46:
      ACCEPT_TOKEN(sym_false);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 47:
      ACCEPT_TOKEN(sym_null);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 48:
      ACCEPT_TOKEN(sym_comment);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(48);
      END_STATE();
    default:
      return false;
  }
}

static const TSLexMode ts_lex_modes[STATE_COUNT] = {
  [0] = {.lex_state = 0},
  [1] = {.lex_state = 11},
  [2] = {.lex_state = 11},
  [3] = {.lex_state = 11},
  [4] = {.lex_state = 11},
  [5] = {.lex_state = 11},
  [6] = {.lex_state = 11},
  [7] = {.lex_state = 11},
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
  [69] = {.lex_state = 5},
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
    [sym_comment] = ACTIONS(3),
  },
  [1] = {
    [sym_document] = STATE(65),
    [sym_top_level_struct] = STATE(63),
    [sym_struct] = STATE(63),
    [sym_map] = STATE(63),
    [sym_array] = STATE(63),
    [sym_struct_field] = STATE(41),
    [sym_string] = STATE(63),
    [ts_builtin_sym_end] = ACTIONS(5),
    [anon_sym_LBRACE] = ACTIONS(7),
    [anon_sym_LBRACK] = ACTIONS(9),
    [anon_sym_DOT] = ACTIONS(11),
    [sym_identifier] = ACTIONS(13),
    [anon_sym_DQUOTE] = ACTIONS(15),
    [sym_number] = ACTIONS(17),
    [sym_true] = ACTIONS(19),
    [sym_false] = ACTIONS(19),
    [sym_null] = ACTIONS(19),
    [sym_comment] = ACTIONS(3),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 10,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      sym_identifier,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_RBRACK,
    ACTIONS(23), 1,
      anon_sym_AT,
    ACTIONS(25), 1,
      sym_number,
    ACTIONS(27), 3,
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
  [38] = 10,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      sym_identifier,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(23), 1,
      anon_sym_AT,
    ACTIONS(29), 1,
      anon_sym_RBRACK,
    ACTIONS(31), 1,
      sym_number,
    ACTIONS(33), 3,
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
  [76] = 10,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      sym_identifier,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(23), 1,
      anon_sym_AT,
    ACTIONS(25), 1,
      sym_number,
    ACTIONS(35), 1,
      anon_sym_RBRACK,
    ACTIONS(27), 3,
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
  [114] = 9,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      sym_identifier,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(23), 1,
      anon_sym_AT,
    ACTIONS(25), 1,
      sym_number,
    ACTIONS(27), 3,
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
  [149] = 9,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      sym_identifier,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(23), 1,
      anon_sym_AT,
    ACTIONS(37), 1,
      sym_number,
    ACTIONS(39), 3,
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
  [184] = 9,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      sym_identifier,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(23), 1,
      anon_sym_AT,
    ACTIONS(41), 1,
      sym_number,
    ACTIONS(43), 3,
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
  [219] = 7,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(11), 1,
      anon_sym_DOT,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(45), 1,
      anon_sym_RBRACE,
    STATE(36), 1,
      sym_map_field,
    STATE(43), 1,
      sym_struct_field,
    STATE(70), 1,
      sym_string,
  [241] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(47), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_COLON,
      anon_sym_RPAREN,
  [253] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(49), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_COLON,
      anon_sym_RPAREN,
  [265] = 5,
    ACTIONS(51), 1,
      anon_sym_DQUOTE,
    ACTIONS(55), 1,
      sym_comment,
    STATE(23), 1,
      aux_sym_string_content_repeat1,
    STATE(64), 1,
      sym_string_content,
    ACTIONS(53), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [282] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(57), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [292] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(59), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [302] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(61), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [312] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(63), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [322] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(65), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [332] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(67), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [342] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(69), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [352] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(71), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [362] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(73), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [372] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(75), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [382] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(77), 1,
      anon_sym_RBRACE,
    STATE(62), 1,
      sym_map_field,
    STATE(70), 1,
      sym_string,
  [398] = 4,
    ACTIONS(55), 1,
      sym_comment,
    ACTIONS(79), 1,
      anon_sym_DQUOTE,
    STATE(31), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(81), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [412] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(83), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [422] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(85), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [432] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(89), 1,
      anon_sym_COMMA,
    STATE(26), 1,
      aux_sym_top_level_struct_repeat1,
    ACTIONS(87), 2,
      ts_builtin_sym_end,
      anon_sym_RBRACE,
  [446] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(92), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [456] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(94), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [466] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(96), 1,
      anon_sym_RBRACE,
    STATE(62), 1,
      sym_map_field,
    STATE(70), 1,
      sym_string,
  [482] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(98), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [492] = 4,
    ACTIONS(55), 1,
      sym_comment,
    ACTIONS(100), 1,
      anon_sym_DQUOTE,
    STATE(31), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(102), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [506] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(105), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [516] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(87), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [525] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(107), 1,
      anon_sym_LPAREN,
    ACTIONS(109), 1,
      aux_sym_tag_token1,
    STATE(34), 1,
      aux_sym_tag_repeat1,
  [538] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(96), 1,
      anon_sym_RBRACE,
    ACTIONS(112), 1,
      anon_sym_COMMA,
    STATE(49), 1,
      aux_sym_map_repeat1,
  [551] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(114), 1,
      anon_sym_COMMA,
    ACTIONS(116), 1,
      anon_sym_RBRACE,
    STATE(35), 1,
      aux_sym_map_repeat1,
  [564] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(118), 1,
      anon_sym_LPAREN,
    ACTIONS(120), 1,
      aux_sym_tag_token1,
    STATE(34), 1,
      aux_sym_tag_repeat1,
  [577] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(21), 1,
      anon_sym_RBRACK,
    ACTIONS(122), 1,
      anon_sym_COMMA,
    STATE(56), 1,
      aux_sym_array_repeat1,
  [590] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(11), 1,
      anon_sym_DOT,
    ACTIONS(124), 1,
      anon_sym_RBRACE,
    STATE(33), 1,
      sym_struct_field,
  [603] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(126), 1,
      anon_sym_COMMA,
    ACTIONS(128), 1,
      anon_sym_RBRACE,
    STATE(54), 1,
      aux_sym_top_level_struct_repeat1,
  [616] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(130), 1,
      ts_builtin_sym_end,
    ACTIONS(132), 1,
      anon_sym_COMMA,
    STATE(46), 1,
      aux_sym_top_level_struct_repeat1,
  [629] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(11), 1,
      anon_sym_DOT,
    ACTIONS(134), 1,
      ts_builtin_sym_end,
    STATE(33), 1,
      sym_struct_field,
  [642] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(136), 1,
      anon_sym_COMMA,
    ACTIONS(138), 1,
      anon_sym_RBRACE,
    STATE(52), 1,
      aux_sym_top_level_struct_repeat1,
  [655] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(11), 1,
      anon_sym_DOT,
    ACTIONS(140), 1,
      anon_sym_RBRACE,
    STATE(33), 1,
      sym_struct_field,
  [668] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(11), 1,
      anon_sym_DOT,
    ACTIONS(142), 1,
      anon_sym_RBRACE,
    STATE(33), 1,
      sym_struct_field,
  [681] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(144), 1,
      ts_builtin_sym_end,
    ACTIONS(146), 1,
      anon_sym_COMMA,
    STATE(26), 1,
      aux_sym_top_level_struct_repeat1,
  [694] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(148), 1,
      aux_sym_tag_token1,
    STATE(37), 1,
      aux_sym_tag_repeat1,
    STATE(71), 1,
      sym_tag,
  [707] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(11), 1,
      anon_sym_DOT,
    ACTIONS(144), 1,
      ts_builtin_sym_end,
    STATE(33), 1,
      sym_struct_field,
  [720] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(150), 1,
      anon_sym_COMMA,
    ACTIONS(153), 1,
      anon_sym_RBRACE,
    STATE(49), 1,
      aux_sym_map_repeat1,
  [733] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(155), 1,
      anon_sym_COMMA,
    ACTIONS(157), 1,
      anon_sym_RBRACK,
    STATE(38), 1,
      aux_sym_array_repeat1,
  [746] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    STATE(62), 1,
      sym_map_field,
    STATE(70), 1,
      sym_string,
  [759] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(140), 1,
      anon_sym_RBRACE,
    ACTIONS(159), 1,
      anon_sym_COMMA,
    STATE(26), 1,
      aux_sym_top_level_struct_repeat1,
  [772] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(11), 1,
      anon_sym_DOT,
    ACTIONS(161), 1,
      anon_sym_RBRACE,
    STATE(40), 1,
      sym_struct_field,
  [785] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(163), 1,
      anon_sym_COMMA,
    ACTIONS(165), 1,
      anon_sym_RBRACE,
    STATE(26), 1,
      aux_sym_top_level_struct_repeat1,
  [798] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(11), 1,
      anon_sym_DOT,
    ACTIONS(165), 1,
      anon_sym_RBRACE,
    STATE(33), 1,
      sym_struct_field,
  [811] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(167), 1,
      anon_sym_COMMA,
    ACTIONS(170), 1,
      anon_sym_RBRACK,
    STATE(56), 1,
      aux_sym_array_repeat1,
  [824] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(172), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [833] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(170), 2,
      anon_sym_COMMA,
      anon_sym_RBRACK,
  [841] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(11), 1,
      anon_sym_DOT,
    STATE(33), 1,
      sym_struct_field,
  [851] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    STATE(67), 1,
      sym_string,
  [861] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(174), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [869] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(153), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [877] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(176), 1,
      ts_builtin_sym_end,
  [884] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(178), 1,
      anon_sym_DQUOTE,
  [891] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(180), 1,
      ts_builtin_sym_end,
  [898] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(182), 1,
      anon_sym_EQ,
  [905] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(184), 1,
      anon_sym_RPAREN,
  [912] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(186), 1,
      anon_sym_LBRACE,
  [919] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(188), 1,
      sym_identifier,
  [926] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(190), 1,
      anon_sym_COLON,
  [933] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(192), 1,
      anon_sym_LPAREN,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(2)] = 0,
  [SMALL_STATE(3)] = 38,
  [SMALL_STATE(4)] = 76,
  [SMALL_STATE(5)] = 114,
  [SMALL_STATE(6)] = 149,
  [SMALL_STATE(7)] = 184,
  [SMALL_STATE(8)] = 219,
  [SMALL_STATE(9)] = 241,
  [SMALL_STATE(10)] = 253,
  [SMALL_STATE(11)] = 265,
  [SMALL_STATE(12)] = 282,
  [SMALL_STATE(13)] = 292,
  [SMALL_STATE(14)] = 302,
  [SMALL_STATE(15)] = 312,
  [SMALL_STATE(16)] = 322,
  [SMALL_STATE(17)] = 332,
  [SMALL_STATE(18)] = 342,
  [SMALL_STATE(19)] = 352,
  [SMALL_STATE(20)] = 362,
  [SMALL_STATE(21)] = 372,
  [SMALL_STATE(22)] = 382,
  [SMALL_STATE(23)] = 398,
  [SMALL_STATE(24)] = 412,
  [SMALL_STATE(25)] = 422,
  [SMALL_STATE(26)] = 432,
  [SMALL_STATE(27)] = 446,
  [SMALL_STATE(28)] = 456,
  [SMALL_STATE(29)] = 466,
  [SMALL_STATE(30)] = 482,
  [SMALL_STATE(31)] = 492,
  [SMALL_STATE(32)] = 506,
  [SMALL_STATE(33)] = 516,
  [SMALL_STATE(34)] = 525,
  [SMALL_STATE(35)] = 538,
  [SMALL_STATE(36)] = 551,
  [SMALL_STATE(37)] = 564,
  [SMALL_STATE(38)] = 577,
  [SMALL_STATE(39)] = 590,
  [SMALL_STATE(40)] = 603,
  [SMALL_STATE(41)] = 616,
  [SMALL_STATE(42)] = 629,
  [SMALL_STATE(43)] = 642,
  [SMALL_STATE(44)] = 655,
  [SMALL_STATE(45)] = 668,
  [SMALL_STATE(46)] = 681,
  [SMALL_STATE(47)] = 694,
  [SMALL_STATE(48)] = 707,
  [SMALL_STATE(49)] = 720,
  [SMALL_STATE(50)] = 733,
  [SMALL_STATE(51)] = 746,
  [SMALL_STATE(52)] = 759,
  [SMALL_STATE(53)] = 772,
  [SMALL_STATE(54)] = 785,
  [SMALL_STATE(55)] = 798,
  [SMALL_STATE(56)] = 811,
  [SMALL_STATE(57)] = 824,
  [SMALL_STATE(58)] = 833,
  [SMALL_STATE(59)] = 841,
  [SMALL_STATE(60)] = 851,
  [SMALL_STATE(61)] = 861,
  [SMALL_STATE(62)] = 869,
  [SMALL_STATE(63)] = 877,
  [SMALL_STATE(64)] = 884,
  [SMALL_STATE(65)] = 891,
  [SMALL_STATE(66)] = 898,
  [SMALL_STATE(67)] = 905,
  [SMALL_STATE(68)] = 912,
  [SMALL_STATE(69)] = 919,
  [SMALL_STATE(70)] = 926,
  [SMALL_STATE(71)] = 933,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, SHIFT_EXTRA(),
  [5] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 0),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(8),
  [9] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [11] = {.entry = {.count = 1, .reusable = true}}, SHIFT(69),
  [13] = {.entry = {.count = 1, .reusable = false}}, SHIFT(68),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(11),
  [17] = {.entry = {.count = 1, .reusable = true}}, SHIFT(63),
  [19] = {.entry = {.count = 1, .reusable = false}}, SHIFT(63),
  [21] = {.entry = {.count = 1, .reusable = true}}, SHIFT(12),
  [23] = {.entry = {.count = 1, .reusable = true}}, SHIFT(47),
  [25] = {.entry = {.count = 1, .reusable = true}}, SHIFT(58),
  [27] = {.entry = {.count = 1, .reusable = false}}, SHIFT(58),
  [29] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [31] = {.entry = {.count = 1, .reusable = true}}, SHIFT(50),
  [33] = {.entry = {.count = 1, .reusable = false}}, SHIFT(50),
  [35] = {.entry = {.count = 1, .reusable = true}}, SHIFT(18),
  [37] = {.entry = {.count = 1, .reusable = true}}, SHIFT(57),
  [39] = {.entry = {.count = 1, .reusable = false}}, SHIFT(57),
  [41] = {.entry = {.count = 1, .reusable = true}}, SHIFT(61),
  [43] = {.entry = {.count = 1, .reusable = false}}, SHIFT(61),
  [45] = {.entry = {.count = 1, .reusable = true}}, SHIFT(32),
  [47] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 3),
  [49] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 2),
  [51] = {.entry = {.count = 1, .reusable = false}}, SHIFT(10),
  [53] = {.entry = {.count = 1, .reusable = true}}, SHIFT(23),
  [55] = {.entry = {.count = 1, .reusable = false}}, SHIFT_EXTRA(),
  [57] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 4),
  [59] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3, .production_id = 1),
  [61] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6, .production_id = 1),
  [63] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag_string, 5, .production_id = 4),
  [65] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5, .production_id = 1),
  [67] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 2),
  [69] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 5),
  [71] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 5),
  [73] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5),
  [75] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4, .production_id = 1),
  [77] = {.entry = {.count = 1, .reusable = true}}, SHIFT(19),
  [79] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_string_content, 1),
  [81] = {.entry = {.count = 1, .reusable = true}}, SHIFT(31),
  [83] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 4),
  [85] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4),
  [87] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2),
  [89] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2), SHIFT_REPEAT(59),
  [92] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3),
  [94] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [96] = {.entry = {.count = 1, .reusable = true}}, SHIFT(24),
  [98] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 3),
  [100] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_string_content_repeat1, 2),
  [102] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_string_content_repeat1, 2), SHIFT_REPEAT(31),
  [105] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 2),
  [107] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2),
  [109] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2), SHIFT_REPEAT(34),
  [112] = {.entry = {.count = 1, .reusable = true}}, SHIFT(22),
  [114] = {.entry = {.count = 1, .reusable = true}}, SHIFT(29),
  [116] = {.entry = {.count = 1, .reusable = true}}, SHIFT(30),
  [118] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 1),
  [120] = {.entry = {.count = 1, .reusable = true}}, SHIFT(34),
  [122] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [124] = {.entry = {.count = 1, .reusable = true}}, SHIFT(14),
  [126] = {.entry = {.count = 1, .reusable = true}}, SHIFT(55),
  [128] = {.entry = {.count = 1, .reusable = true}}, SHIFT(21),
  [130] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 1),
  [132] = {.entry = {.count = 1, .reusable = true}}, SHIFT(48),
  [134] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 3),
  [136] = {.entry = {.count = 1, .reusable = true}}, SHIFT(44),
  [138] = {.entry = {.count = 1, .reusable = true}}, SHIFT(27),
  [140] = {.entry = {.count = 1, .reusable = true}}, SHIFT(25),
  [142] = {.entry = {.count = 1, .reusable = true}}, SHIFT(20),
  [144] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 2),
  [146] = {.entry = {.count = 1, .reusable = true}}, SHIFT(42),
  [148] = {.entry = {.count = 1, .reusable = true}}, SHIFT(37),
  [150] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2), SHIFT_REPEAT(51),
  [153] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2),
  [155] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [157] = {.entry = {.count = 1, .reusable = true}}, SHIFT(28),
  [159] = {.entry = {.count = 1, .reusable = true}}, SHIFT(45),
  [161] = {.entry = {.count = 1, .reusable = true}}, SHIFT(13),
  [163] = {.entry = {.count = 1, .reusable = true}}, SHIFT(39),
  [165] = {.entry = {.count = 1, .reusable = true}}, SHIFT(16),
  [167] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2), SHIFT_REPEAT(5),
  [170] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2),
  [172] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 4, .production_id = 3),
  [174] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map_field, 3, .production_id = 2),
  [176] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 1),
  [178] = {.entry = {.count = 1, .reusable = true}}, SHIFT(9),
  [180] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [182] = {.entry = {.count = 1, .reusable = true}}, SHIFT(6),
  [184] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [186] = {.entry = {.count = 1, .reusable = true}}, SHIFT(53),
  [188] = {.entry = {.count = 1, .reusable = true}}, SHIFT(66),
  [190] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [192] = {.entry = {.count = 1, .reusable = true}}, SHIFT(60),
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
