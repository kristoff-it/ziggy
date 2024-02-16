#include <tree_sitter/parser.h>

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 14
#define STATE_COUNT 63
#define LARGE_STATE_COUNT 2
#define SYMBOL_COUNT 38
#define ALIAS_COUNT 0
#define TOKEN_COUNT 21
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 2
#define MAX_ALIAS_SEQUENCE_LENGTH 5
#define PRODUCTION_ID_COUNT 2

enum {
  anon_sym_COMMA = 1,
  anon_sym_DOT_LBRACE = 2,
  anon_sym_RBRACE = 3,
  anon_sym_COLON_LBRACE = 4,
  anon_sym_LBRACK = 5,
  anon_sym_RBRACK = 6,
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
  [anon_sym_DOT_LBRACE] = ".{",
  [anon_sym_RBRACE] = "}",
  [anon_sym_COLON_LBRACE] = ":{",
  [anon_sym_LBRACK] = "[",
  [anon_sym_RBRACK] = "]",
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
  [anon_sym_DOT_LBRACE] = anon_sym_DOT_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
  [anon_sym_COLON_LBRACE] = anon_sym_COLON_LBRACE,
  [anon_sym_LBRACK] = anon_sym_LBRACK,
  [anon_sym_RBRACK] = anon_sym_RBRACK,
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
  [anon_sym_DOT_LBRACE] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_RBRACE] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_COLON_LBRACE] = {
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
  field_value = 2,
};

static const char * const ts_field_names[] = {
  [0] = NULL,
  [field_key] = "key",
  [field_value] = "value",
};

static const TSFieldMapSlice ts_field_map_slices[PRODUCTION_ID_COUNT] = {
  [1] = {.index = 0, .length = 2},
};

static const TSFieldMapEntry ts_field_map_entries[] = {
  [0] =
    {field_key, 0},
    {field_value, 2},
};

static const TSSymbol ts_alias_sequences[PRODUCTION_ID_COUNT][MAX_ALIAS_SEQUENCE_LENGTH] = {
  [0] = {0},
};

static const uint16_t ts_non_terminal_alias_map[] = {
  0,
};

static const TSStateId ts_primary_state_ids[STATE_COUNT] = {
  [0] = 0,
  [1] = 1,
  [2] = 2,
  [3] = 3,
  [4] = 4,
  [5] = 5,
  [6] = 6,
  [7] = 7,
  [8] = 8,
  [9] = 9,
  [10] = 10,
  [11] = 11,
  [12] = 12,
  [13] = 13,
  [14] = 14,
  [15] = 15,
  [16] = 16,
  [17] = 17,
  [18] = 18,
  [19] = 19,
  [20] = 20,
  [21] = 21,
  [22] = 22,
  [23] = 23,
  [24] = 24,
  [25] = 25,
  [26] = 26,
  [27] = 27,
  [28] = 28,
  [29] = 29,
  [30] = 30,
  [31] = 31,
  [32] = 32,
  [33] = 33,
  [34] = 34,
  [35] = 35,
  [36] = 36,
  [37] = 37,
  [38] = 38,
  [39] = 39,
  [40] = 40,
  [41] = 41,
  [42] = 42,
  [43] = 43,
  [44] = 44,
  [45] = 45,
  [46] = 46,
  [47] = 47,
  [48] = 48,
  [49] = 49,
  [50] = 50,
  [51] = 51,
  [52] = 52,
  [53] = 53,
  [54] = 54,
  [55] = 55,
  [56] = 56,
  [57] = 57,
  [58] = 58,
  [59] = 59,
  [60] = 60,
  [61] = 61,
  [62] = 62,
};

static bool ts_lex(TSLexer *lexer, TSStateId state) {
  START_LEXER();
  eof = lexer->eof(lexer);
  switch (state) {
    case 0:
      if (eof) ADVANCE(22);
      if (lookahead == '"') ADVANCE(37);
      if (lookahead == '(') ADVANCE(34);
      if (lookahead == ')') ADVANCE(35);
      if (lookahead == ',') ADVANCE(23);
      if (lookahead == '-') ADVANCE(4);
      if (lookahead == '.') ADVANCE(15);
      if (lookahead == '0') ADVANCE(41);
      if (lookahead == ':') ADVANCE(32);
      if (lookahead == '=') ADVANCE(29);
      if (lookahead == '@') ADVANCE(33);
      if (lookahead == '[') ADVANCE(27);
      if (lookahead == '\\') ADVANCE(17);
      if (lookahead == ']') ADVANCE(28);
      if (lookahead == '}') ADVANCE(25);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(19)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(42);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(36);
      END_STATE();
    case 1:
      if (lookahead == '\n') SKIP(2)
      if (lookahead == '"') ADVANCE(37);
      if (lookahead == '\\') ADVANCE(17);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(38);
      if (lookahead != 0) ADVANCE(39);
      END_STATE();
    case 2:
      if (lookahead == '"') ADVANCE(37);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(2)
      END_STATE();
    case 3:
      if (lookahead == '-') ADVANCE(18);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(44);
      END_STATE();
    case 4:
      if (lookahead == '0') ADVANCE(41);
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(42);
      END_STATE();
    case 5:
      if (lookahead == 'a') ADVANCE(8);
      END_STATE();
    case 6:
      if (lookahead == 'e') ADVANCE(45);
      END_STATE();
    case 7:
      if (lookahead == 'e') ADVANCE(46);
      END_STATE();
    case 8:
      if (lookahead == 'l') ADVANCE(12);
      END_STATE();
    case 9:
      if (lookahead == 'l') ADVANCE(47);
      END_STATE();
    case 10:
      if (lookahead == 'l') ADVANCE(9);
      END_STATE();
    case 11:
      if (lookahead == 'r') ADVANCE(13);
      END_STATE();
    case 12:
      if (lookahead == 's') ADVANCE(7);
      END_STATE();
    case 13:
      if (lookahead == 'u') ADVANCE(6);
      END_STATE();
    case 14:
      if (lookahead == 'u') ADVANCE(10);
      END_STATE();
    case 15:
      if (lookahead == '{') ADVANCE(24);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 16:
      if (lookahead == '{') ADVANCE(26);
      END_STATE();
    case 17:
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
    case 18:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(44);
      END_STATE();
    case 19:
      if (eof) ADVANCE(22);
      if (lookahead == '"') ADVANCE(37);
      if (lookahead == '(') ADVANCE(34);
      if (lookahead == ')') ADVANCE(35);
      if (lookahead == ',') ADVANCE(23);
      if (lookahead == '-') ADVANCE(4);
      if (lookahead == '.') ADVANCE(15);
      if (lookahead == '0') ADVANCE(41);
      if (lookahead == ':') ADVANCE(32);
      if (lookahead == '=') ADVANCE(29);
      if (lookahead == '@') ADVANCE(33);
      if (lookahead == '[') ADVANCE(27);
      if (lookahead == ']') ADVANCE(28);
      if (lookahead == '}') ADVANCE(25);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(19)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(42);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(36);
      END_STATE();
    case 20:
      if (eof) ADVANCE(22);
      if (lookahead == '"') ADVANCE(37);
      if (lookahead == '-') ADVANCE(4);
      if (lookahead == '.') ADVANCE(15);
      if (lookahead == '0') ADVANCE(41);
      if (lookahead == ':') ADVANCE(16);
      if (lookahead == '@') ADVANCE(33);
      if (lookahead == '[') ADVANCE(27);
      if (lookahead == ']') ADVANCE(28);
      if (lookahead == 'f') ADVANCE(5);
      if (lookahead == 'n') ADVANCE(14);
      if (lookahead == 't') ADVANCE(11);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(20)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(42);
      END_STATE();
    case 21:
      if (eof) ADVANCE(22);
      if (lookahead == ')') ADVANCE(35);
      if (lookahead == ',') ADVANCE(23);
      if (lookahead == ':') ADVANCE(31);
      if (lookahead == ']') ADVANCE(28);
      if (lookahead == '}') ADVANCE(25);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(21)
      END_STATE();
    case 22:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 23:
      ACCEPT_TOKEN(anon_sym_COMMA);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(anon_sym_DOT_LBRACE);
      END_STATE();
    case 25:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 26:
      ACCEPT_TOKEN(anon_sym_COLON_LBRACE);
      END_STATE();
    case 27:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 28:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 29:
      ACCEPT_TOKEN(anon_sym_EQ);
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
      ACCEPT_TOKEN(anon_sym_COLON);
      if (lookahead == '{') ADVANCE(26);
      END_STATE();
    case 33:
      ACCEPT_TOKEN(anon_sym_AT);
      END_STATE();
    case 34:
      ACCEPT_TOKEN(anon_sym_LPAREN);
      END_STATE();
    case 35:
      ACCEPT_TOKEN(anon_sym_RPAREN);
      END_STATE();
    case 36:
      ACCEPT_TOKEN(aux_sym_tag_token1);
      END_STATE();
    case 37:
      ACCEPT_TOKEN(anon_sym_DQUOTE);
      END_STATE();
    case 38:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(38);
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
          lookahead == 'e') ADVANCE(3);
      END_STATE();
    case 42:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(43);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(3);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(42);
      END_STATE();
    case 43:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(3);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(43);
      END_STATE();
    case 44:
      ACCEPT_TOKEN(sym_number);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(44);
      END_STATE();
    case 45:
      ACCEPT_TOKEN(sym_true);
      END_STATE();
    case 46:
      ACCEPT_TOKEN(sym_false);
      END_STATE();
    case 47:
      ACCEPT_TOKEN(sym_null);
      END_STATE();
    default:
      return false;
  }
}

static const TSLexMode ts_lex_modes[STATE_COUNT] = {
  [0] = {.lex_state = 0},
  [1] = {.lex_state = 20},
  [2] = {.lex_state = 20},
  [3] = {.lex_state = 20},
  [4] = {.lex_state = 20},
  [5] = {.lex_state = 20},
  [6] = {.lex_state = 20},
  [7] = {.lex_state = 20},
  [8] = {.lex_state = 21},
  [9] = {.lex_state = 21},
  [10] = {.lex_state = 1},
  [11] = {.lex_state = 0},
  [12] = {.lex_state = 0},
  [13] = {.lex_state = 0},
  [14] = {.lex_state = 0},
  [15] = {.lex_state = 0},
  [16] = {.lex_state = 0},
  [17] = {.lex_state = 0},
  [18] = {.lex_state = 0},
  [19] = {.lex_state = 0},
  [20] = {.lex_state = 0},
  [21] = {.lex_state = 1},
  [22] = {.lex_state = 0},
  [23] = {.lex_state = 1},
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
  [52] = {.lex_state = 0},
  [53] = {.lex_state = 0},
  [54] = {.lex_state = 0},
  [55] = {.lex_state = 0},
  [56] = {.lex_state = 21},
  [57] = {.lex_state = 0},
  [58] = {.lex_state = 0},
  [59] = {.lex_state = 0},
  [60] = {.lex_state = 0},
  [61] = {.lex_state = 0},
  [62] = {.lex_state = 0},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
    [anon_sym_DOT_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
    [anon_sym_COLON_LBRACE] = ACTIONS(1),
    [anon_sym_LBRACK] = ACTIONS(1),
    [anon_sym_RBRACK] = ACTIONS(1),
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
    [sym_document] = STATE(60),
    [sym_top_level_struct] = STATE(61),
    [sym_struct] = STATE(61),
    [sym_map] = STATE(61),
    [sym_array] = STATE(61),
    [sym_struct_field] = STATE(45),
    [sym_string] = STATE(61),
    [ts_builtin_sym_end] = ACTIONS(3),
    [anon_sym_DOT_LBRACE] = ACTIONS(5),
    [anon_sym_COLON_LBRACE] = ACTIONS(7),
    [anon_sym_LBRACK] = ACTIONS(9),
    [sym_identifier] = ACTIONS(11),
    [anon_sym_DQUOTE] = ACTIONS(13),
    [sym_number] = ACTIONS(15),
    [sym_true] = ACTIONS(15),
    [sym_false] = ACTIONS(15),
    [sym_null] = ACTIONS(15),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 8,
    ACTIONS(5), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(7), 1,
      anon_sym_COLON_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(17), 1,
      anon_sym_RBRACK,
    ACTIONS(19), 1,
      anon_sym_AT,
    ACTIONS(21), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(51), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [33] = 8,
    ACTIONS(5), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(7), 1,
      anon_sym_COLON_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_AT,
    ACTIONS(23), 1,
      anon_sym_RBRACK,
    ACTIONS(21), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(51), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [66] = 8,
    ACTIONS(5), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(7), 1,
      anon_sym_COLON_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_AT,
    ACTIONS(25), 1,
      anon_sym_RBRACK,
    ACTIONS(27), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(46), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [99] = 7,
    ACTIONS(5), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(7), 1,
      anon_sym_COLON_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_AT,
    ACTIONS(21), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(51), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [129] = 7,
    ACTIONS(5), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(7), 1,
      anon_sym_COLON_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_AT,
    ACTIONS(29), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(36), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [159] = 7,
    ACTIONS(5), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(7), 1,
      anon_sym_COLON_LBRACE,
    ACTIONS(9), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_AT,
    ACTIONS(31), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(53), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [189] = 1,
    ACTIONS(33), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_COLON,
      anon_sym_RPAREN,
  [198] = 1,
    ACTIONS(35), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_COLON,
      anon_sym_RPAREN,
  [207] = 4,
    ACTIONS(37), 1,
      anon_sym_DQUOTE,
    STATE(21), 1,
      aux_sym_string_content_repeat1,
    STATE(58), 1,
      sym_string_content,
    ACTIONS(39), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [221] = 4,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(41), 1,
      anon_sym_RBRACE,
    STATE(55), 1,
      sym_map_field,
    STATE(56), 1,
      sym_string,
  [234] = 1,
    ACTIONS(43), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [241] = 1,
    ACTIONS(45), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [248] = 1,
    ACTIONS(47), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [255] = 1,
    ACTIONS(49), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [262] = 1,
    ACTIONS(51), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [269] = 1,
    ACTIONS(53), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [276] = 1,
    ACTIONS(55), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [283] = 1,
    ACTIONS(57), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [290] = 1,
    ACTIONS(59), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [297] = 3,
    ACTIONS(61), 1,
      anon_sym_DQUOTE,
    STATE(23), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(63), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [308] = 3,
    ACTIONS(67), 1,
      anon_sym_COMMA,
    STATE(22), 1,
      aux_sym_top_level_struct_repeat1,
    ACTIONS(65), 2,
      ts_builtin_sym_end,
      anon_sym_RBRACE,
  [319] = 3,
    ACTIONS(70), 1,
      anon_sym_DQUOTE,
    STATE(23), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(72), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [330] = 1,
    ACTIONS(75), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [337] = 1,
    ACTIONS(77), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [344] = 1,
    ACTIONS(79), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [351] = 4,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(81), 1,
      anon_sym_RBRACE,
    STATE(55), 1,
      sym_map_field,
    STATE(56), 1,
      sym_string,
  [364] = 1,
    ACTIONS(83), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [371] = 4,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    ACTIONS(85), 1,
      anon_sym_RBRACE,
    STATE(49), 1,
      sym_map_field,
    STATE(56), 1,
      sym_string,
  [384] = 3,
    ACTIONS(87), 1,
      aux_sym_tag_token1,
    STATE(32), 1,
      aux_sym_tag_repeat1,
    STATE(57), 1,
      sym_tag,
  [394] = 3,
    ACTIONS(89), 1,
      anon_sym_COMMA,
    ACTIONS(92), 1,
      anon_sym_RBRACE,
    STATE(31), 1,
      aux_sym_map_repeat1,
  [404] = 3,
    ACTIONS(94), 1,
      anon_sym_LPAREN,
    ACTIONS(96), 1,
      aux_sym_tag_token1,
    STATE(50), 1,
      aux_sym_tag_repeat1,
  [414] = 3,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(98), 1,
      anon_sym_RBRACE,
    STATE(47), 1,
      sym_struct_field,
  [424] = 3,
    ACTIONS(81), 1,
      anon_sym_RBRACE,
    ACTIONS(100), 1,
      anon_sym_COMMA,
    STATE(31), 1,
      aux_sym_map_repeat1,
  [434] = 3,
    ACTIONS(23), 1,
      anon_sym_RBRACK,
    ACTIONS(102), 1,
      anon_sym_COMMA,
    STATE(48), 1,
      aux_sym_array_repeat1,
  [444] = 1,
    ACTIONS(104), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [450] = 3,
    ACTIONS(106), 1,
      anon_sym_COMMA,
    ACTIONS(108), 1,
      anon_sym_RBRACE,
    STATE(22), 1,
      aux_sym_top_level_struct_repeat1,
  [460] = 3,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(108), 1,
      anon_sym_RBRACE,
    STATE(39), 1,
      sym_struct_field,
  [470] = 1,
    ACTIONS(65), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [476] = 3,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(110), 1,
      ts_builtin_sym_end,
    STATE(39), 1,
      sym_struct_field,
  [486] = 3,
    ACTIONS(112), 1,
      ts_builtin_sym_end,
    ACTIONS(114), 1,
      anon_sym_COMMA,
    STATE(22), 1,
      aux_sym_top_level_struct_repeat1,
  [496] = 3,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(112), 1,
      ts_builtin_sym_end,
    STATE(39), 1,
      sym_struct_field,
  [506] = 3,
    ACTIONS(11), 1,
      sym_identifier,
    ACTIONS(116), 1,
      anon_sym_RBRACE,
    STATE(39), 1,
      sym_struct_field,
  [516] = 3,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    STATE(55), 1,
      sym_map_field,
    STATE(56), 1,
      sym_string,
  [526] = 3,
    ACTIONS(118), 1,
      ts_builtin_sym_end,
    ACTIONS(120), 1,
      anon_sym_COMMA,
    STATE(41), 1,
      aux_sym_top_level_struct_repeat1,
  [536] = 3,
    ACTIONS(122), 1,
      anon_sym_COMMA,
    ACTIONS(124), 1,
      anon_sym_RBRACK,
    STATE(35), 1,
      aux_sym_array_repeat1,
  [546] = 3,
    ACTIONS(126), 1,
      anon_sym_COMMA,
    ACTIONS(128), 1,
      anon_sym_RBRACE,
    STATE(37), 1,
      aux_sym_top_level_struct_repeat1,
  [556] = 3,
    ACTIONS(130), 1,
      anon_sym_COMMA,
    ACTIONS(133), 1,
      anon_sym_RBRACK,
    STATE(48), 1,
      aux_sym_array_repeat1,
  [566] = 3,
    ACTIONS(135), 1,
      anon_sym_COMMA,
    ACTIONS(137), 1,
      anon_sym_RBRACE,
    STATE(34), 1,
      aux_sym_map_repeat1,
  [576] = 3,
    ACTIONS(139), 1,
      anon_sym_LPAREN,
    ACTIONS(141), 1,
      aux_sym_tag_token1,
    STATE(50), 1,
      aux_sym_tag_repeat1,
  [586] = 1,
    ACTIONS(133), 2,
      anon_sym_COMMA,
      anon_sym_RBRACK,
  [591] = 2,
    ACTIONS(13), 1,
      anon_sym_DQUOTE,
    STATE(59), 1,
      sym_string,
  [598] = 1,
    ACTIONS(144), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [603] = 2,
    ACTIONS(11), 1,
      sym_identifier,
    STATE(39), 1,
      sym_struct_field,
  [610] = 1,
    ACTIONS(92), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [615] = 1,
    ACTIONS(146), 1,
      anon_sym_COLON,
  [619] = 1,
    ACTIONS(148), 1,
      anon_sym_LPAREN,
  [623] = 1,
    ACTIONS(150), 1,
      anon_sym_DQUOTE,
  [627] = 1,
    ACTIONS(152), 1,
      anon_sym_RPAREN,
  [631] = 1,
    ACTIONS(154), 1,
      ts_builtin_sym_end,
  [635] = 1,
    ACTIONS(156), 1,
      ts_builtin_sym_end,
  [639] = 1,
    ACTIONS(158), 1,
      anon_sym_EQ,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(2)] = 0,
  [SMALL_STATE(3)] = 33,
  [SMALL_STATE(4)] = 66,
  [SMALL_STATE(5)] = 99,
  [SMALL_STATE(6)] = 129,
  [SMALL_STATE(7)] = 159,
  [SMALL_STATE(8)] = 189,
  [SMALL_STATE(9)] = 198,
  [SMALL_STATE(10)] = 207,
  [SMALL_STATE(11)] = 221,
  [SMALL_STATE(12)] = 234,
  [SMALL_STATE(13)] = 241,
  [SMALL_STATE(14)] = 248,
  [SMALL_STATE(15)] = 255,
  [SMALL_STATE(16)] = 262,
  [SMALL_STATE(17)] = 269,
  [SMALL_STATE(18)] = 276,
  [SMALL_STATE(19)] = 283,
  [SMALL_STATE(20)] = 290,
  [SMALL_STATE(21)] = 297,
  [SMALL_STATE(22)] = 308,
  [SMALL_STATE(23)] = 319,
  [SMALL_STATE(24)] = 330,
  [SMALL_STATE(25)] = 337,
  [SMALL_STATE(26)] = 344,
  [SMALL_STATE(27)] = 351,
  [SMALL_STATE(28)] = 364,
  [SMALL_STATE(29)] = 371,
  [SMALL_STATE(30)] = 384,
  [SMALL_STATE(31)] = 394,
  [SMALL_STATE(32)] = 404,
  [SMALL_STATE(33)] = 414,
  [SMALL_STATE(34)] = 424,
  [SMALL_STATE(35)] = 434,
  [SMALL_STATE(36)] = 444,
  [SMALL_STATE(37)] = 450,
  [SMALL_STATE(38)] = 460,
  [SMALL_STATE(39)] = 470,
  [SMALL_STATE(40)] = 476,
  [SMALL_STATE(41)] = 486,
  [SMALL_STATE(42)] = 496,
  [SMALL_STATE(43)] = 506,
  [SMALL_STATE(44)] = 516,
  [SMALL_STATE(45)] = 526,
  [SMALL_STATE(46)] = 536,
  [SMALL_STATE(47)] = 546,
  [SMALL_STATE(48)] = 556,
  [SMALL_STATE(49)] = 566,
  [SMALL_STATE(50)] = 576,
  [SMALL_STATE(51)] = 586,
  [SMALL_STATE(52)] = 591,
  [SMALL_STATE(53)] = 598,
  [SMALL_STATE(54)] = 603,
  [SMALL_STATE(55)] = 610,
  [SMALL_STATE(56)] = 615,
  [SMALL_STATE(57)] = 619,
  [SMALL_STATE(58)] = 623,
  [SMALL_STATE(59)] = 627,
  [SMALL_STATE(60)] = 631,
  [SMALL_STATE(61)] = 635,
  [SMALL_STATE(62)] = 639,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 0),
  [5] = {.entry = {.count = 1, .reusable = true}}, SHIFT(33),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(29),
  [9] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [11] = {.entry = {.count = 1, .reusable = true}}, SHIFT(62),
  [13] = {.entry = {.count = 1, .reusable = true}}, SHIFT(10),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(61),
  [17] = {.entry = {.count = 1, .reusable = true}}, SHIFT(24),
  [19] = {.entry = {.count = 1, .reusable = true}}, SHIFT(30),
  [21] = {.entry = {.count = 1, .reusable = true}}, SHIFT(51),
  [23] = {.entry = {.count = 1, .reusable = true}}, SHIFT(14),
  [25] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [27] = {.entry = {.count = 1, .reusable = true}}, SHIFT(46),
  [29] = {.entry = {.count = 1, .reusable = true}}, SHIFT(36),
  [31] = {.entry = {.count = 1, .reusable = true}}, SHIFT(53),
  [33] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 3),
  [35] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 2),
  [37] = {.entry = {.count = 1, .reusable = false}}, SHIFT(9),
  [39] = {.entry = {.count = 1, .reusable = true}}, SHIFT(21),
  [41] = {.entry = {.count = 1, .reusable = true}}, SHIFT(19),
  [43] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 2),
  [45] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 2),
  [47] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 4),
  [49] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 2),
  [51] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag_string, 5),
  [53] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 4),
  [55] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5),
  [57] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 5),
  [59] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4),
  [61] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_string_content, 1),
  [63] = {.entry = {.count = 1, .reusable = true}}, SHIFT(23),
  [65] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2),
  [67] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2), SHIFT_REPEAT(54),
  [70] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_string_content_repeat1, 2),
  [72] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_string_content_repeat1, 2), SHIFT_REPEAT(23),
  [75] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 5),
  [77] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3),
  [79] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [81] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [83] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 3),
  [85] = {.entry = {.count = 1, .reusable = true}}, SHIFT(13),
  [87] = {.entry = {.count = 1, .reusable = true}}, SHIFT(32),
  [89] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2), SHIFT_REPEAT(44),
  [92] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2),
  [94] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 1),
  [96] = {.entry = {.count = 1, .reusable = true}}, SHIFT(50),
  [98] = {.entry = {.count = 1, .reusable = true}}, SHIFT(12),
  [100] = {.entry = {.count = 1, .reusable = true}}, SHIFT(11),
  [102] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [104] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 3, .production_id = 1),
  [106] = {.entry = {.count = 1, .reusable = true}}, SHIFT(43),
  [108] = {.entry = {.count = 1, .reusable = true}}, SHIFT(20),
  [110] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 3),
  [112] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 2),
  [114] = {.entry = {.count = 1, .reusable = true}}, SHIFT(40),
  [116] = {.entry = {.count = 1, .reusable = true}}, SHIFT(18),
  [118] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 1),
  [120] = {.entry = {.count = 1, .reusable = true}}, SHIFT(42),
  [122] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [124] = {.entry = {.count = 1, .reusable = true}}, SHIFT(26),
  [126] = {.entry = {.count = 1, .reusable = true}}, SHIFT(38),
  [128] = {.entry = {.count = 1, .reusable = true}}, SHIFT(25),
  [130] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2), SHIFT_REPEAT(5),
  [133] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2),
  [135] = {.entry = {.count = 1, .reusable = true}}, SHIFT(27),
  [137] = {.entry = {.count = 1, .reusable = true}}, SHIFT(28),
  [139] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2),
  [141] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2), SHIFT_REPEAT(50),
  [144] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map_field, 3, .production_id = 1),
  [146] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [148] = {.entry = {.count = 1, .reusable = true}}, SHIFT(52),
  [150] = {.entry = {.count = 1, .reusable = true}}, SHIFT(8),
  [152] = {.entry = {.count = 1, .reusable = true}}, SHIFT(16),
  [154] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [156] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 1),
  [158] = {.entry = {.count = 1, .reusable = true}}, SHIFT(6),
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
    .primary_state_ids = ts_primary_state_ids,
  };
  return &language;
}
#ifdef __cplusplus
}
#endif
