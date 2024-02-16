#include <tree_sitter/parser.h>

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 14
#define STATE_COUNT 61
#define LARGE_STATE_COUNT 2
#define SYMBOL_COUNT 37
#define ALIAS_COUNT 0
#define TOKEN_COUNT 20
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 2
#define MAX_ALIAS_SEQUENCE_LENGTH 5
#define PRODUCTION_ID_COUNT 2

enum {
  anon_sym_COMMA = 1,
  anon_sym_LBRACE = 2,
  anon_sym_RBRACE = 3,
  anon_sym_LBRACK = 4,
  anon_sym_RBRACK = 5,
  anon_sym_EQ = 6,
  sym_identifier = 7,
  anon_sym_COLON = 8,
  anon_sym_AT = 9,
  anon_sym_LPAREN = 10,
  anon_sym_RPAREN = 11,
  aux_sym_tag_token1 = 12,
  anon_sym_DQUOTE = 13,
  aux_sym_string_content_token1 = 14,
  sym_escape_sequence = 15,
  sym_number = 16,
  sym_true = 17,
  sym_false = 18,
  sym_null = 19,
  sym_document = 20,
  sym__value = 21,
  sym_top_level_struct = 22,
  sym_struct = 23,
  sym_map = 24,
  sym_array = 25,
  sym_struct_field = 26,
  sym_map_field = 27,
  sym_tag_string = 28,
  sym_tag = 29,
  sym_string = 30,
  sym_string_content = 31,
  aux_sym_top_level_struct_repeat1 = 32,
  aux_sym_map_repeat1 = 33,
  aux_sym_array_repeat1 = 34,
  aux_sym_tag_repeat1 = 35,
  aux_sym_string_content_repeat1 = 36,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [anon_sym_COMMA] = ",",
  [anon_sym_LBRACE] = "{",
  [anon_sym_RBRACE] = "}",
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
  [anon_sym_LBRACE] = anon_sym_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
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
};

static bool ts_lex(TSLexer *lexer, TSStateId state) {
  START_LEXER();
  eof = lexer->eof(lexer);
  switch (state) {
    case 0:
      if (eof) ADVANCE(20);
      if (lookahead == '"') ADVANCE(33);
      if (lookahead == '(') ADVANCE(30);
      if (lookahead == ')') ADVANCE(31);
      if (lookahead == ',') ADVANCE(21);
      if (lookahead == '-') ADVANCE(4);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '0') ADVANCE(37);
      if (lookahead == ':') ADVANCE(28);
      if (lookahead == '=') ADVANCE(26);
      if (lookahead == '@') ADVANCE(29);
      if (lookahead == '[') ADVANCE(24);
      if (lookahead == '\\') ADVANCE(15);
      if (lookahead == ']') ADVANCE(25);
      if (lookahead == '{') ADVANCE(22);
      if (lookahead == '}') ADVANCE(23);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(18)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(38);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(32);
      END_STATE();
    case 1:
      if (lookahead == '\n') SKIP(2)
      if (lookahead == '"') ADVANCE(33);
      if (lookahead == '\\') ADVANCE(15);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(34);
      if (lookahead != 0) ADVANCE(35);
      END_STATE();
    case 2:
      if (lookahead == '"') ADVANCE(33);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(2)
      END_STATE();
    case 3:
      if (lookahead == '-') ADVANCE(16);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(40);
      END_STATE();
    case 4:
      if (lookahead == '0') ADVANCE(37);
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(38);
      END_STATE();
    case 5:
      if (lookahead == 'a') ADVANCE(8);
      END_STATE();
    case 6:
      if (lookahead == 'e') ADVANCE(41);
      END_STATE();
    case 7:
      if (lookahead == 'e') ADVANCE(42);
      END_STATE();
    case 8:
      if (lookahead == 'l') ADVANCE(12);
      END_STATE();
    case 9:
      if (lookahead == 'l') ADVANCE(43);
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
      if (lookahead == '"' ||
          lookahead == '/' ||
          lookahead == '\\' ||
          lookahead == 'b' ||
          lookahead == 'f' ||
          lookahead == 'n' ||
          lookahead == 'r' ||
          lookahead == 't' ||
          lookahead == 'u') ADVANCE(36);
      END_STATE();
    case 16:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(40);
      END_STATE();
    case 17:
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(27);
      END_STATE();
    case 18:
      if (eof) ADVANCE(20);
      if (lookahead == '"') ADVANCE(33);
      if (lookahead == '(') ADVANCE(30);
      if (lookahead == ')') ADVANCE(31);
      if (lookahead == ',') ADVANCE(21);
      if (lookahead == '-') ADVANCE(4);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '0') ADVANCE(37);
      if (lookahead == ':') ADVANCE(28);
      if (lookahead == '=') ADVANCE(26);
      if (lookahead == '@') ADVANCE(29);
      if (lookahead == '[') ADVANCE(24);
      if (lookahead == ']') ADVANCE(25);
      if (lookahead == '{') ADVANCE(22);
      if (lookahead == '}') ADVANCE(23);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(18)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(38);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(32);
      END_STATE();
    case 19:
      if (eof) ADVANCE(20);
      if (lookahead == '"') ADVANCE(33);
      if (lookahead == '-') ADVANCE(4);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '0') ADVANCE(37);
      if (lookahead == '@') ADVANCE(29);
      if (lookahead == '[') ADVANCE(24);
      if (lookahead == ']') ADVANCE(25);
      if (lookahead == 'f') ADVANCE(5);
      if (lookahead == 'n') ADVANCE(14);
      if (lookahead == 't') ADVANCE(11);
      if (lookahead == '{') ADVANCE(22);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(19)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(38);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 21:
      ACCEPT_TOKEN(anon_sym_COMMA);
      END_STATE();
    case 22:
      ACCEPT_TOKEN(anon_sym_LBRACE);
      END_STATE();
    case 23:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 25:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 26:
      ACCEPT_TOKEN(anon_sym_EQ);
      END_STATE();
    case 27:
      ACCEPT_TOKEN(sym_identifier);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(27);
      END_STATE();
    case 28:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 29:
      ACCEPT_TOKEN(anon_sym_AT);
      END_STATE();
    case 30:
      ACCEPT_TOKEN(anon_sym_LPAREN);
      END_STATE();
    case 31:
      ACCEPT_TOKEN(anon_sym_RPAREN);
      END_STATE();
    case 32:
      ACCEPT_TOKEN(aux_sym_tag_token1);
      END_STATE();
    case 33:
      ACCEPT_TOKEN(anon_sym_DQUOTE);
      END_STATE();
    case 34:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(34);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(35);
      END_STATE();
    case 35:
      ACCEPT_TOKEN(aux_sym_string_content_token1);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(35);
      END_STATE();
    case 36:
      ACCEPT_TOKEN(sym_escape_sequence);
      END_STATE();
    case 37:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(39);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(3);
      END_STATE();
    case 38:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(39);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(3);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(38);
      END_STATE();
    case 39:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(3);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(39);
      END_STATE();
    case 40:
      ACCEPT_TOKEN(sym_number);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(40);
      END_STATE();
    case 41:
      ACCEPT_TOKEN(sym_true);
      END_STATE();
    case 42:
      ACCEPT_TOKEN(sym_false);
      END_STATE();
    case 43:
      ACCEPT_TOKEN(sym_null);
      END_STATE();
    default:
      return false;
  }
}

static const TSLexMode ts_lex_modes[STATE_COUNT] = {
  [0] = {.lex_state = 0},
  [1] = {.lex_state = 19},
  [2] = {.lex_state = 19},
  [3] = {.lex_state = 19},
  [4] = {.lex_state = 19},
  [5] = {.lex_state = 19},
  [6] = {.lex_state = 19},
  [7] = {.lex_state = 19},
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
  [19] = {.lex_state = 1},
  [20] = {.lex_state = 0},
  [21] = {.lex_state = 1},
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
  [52] = {.lex_state = 0},
  [53] = {.lex_state = 0},
  [54] = {.lex_state = 0},
  [55] = {.lex_state = 0},
  [56] = {.lex_state = 0},
  [57] = {.lex_state = 0},
  [58] = {.lex_state = 0},
  [59] = {.lex_state = 0},
  [60] = {.lex_state = 0},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
    [anon_sym_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
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
    [sym_document] = STATE(59),
    [sym_top_level_struct] = STATE(60),
    [sym_struct] = STATE(60),
    [sym_map] = STATE(60),
    [sym_array] = STATE(60),
    [sym_struct_field] = STATE(31),
    [sym_string] = STATE(60),
    [ts_builtin_sym_end] = ACTIONS(3),
    [anon_sym_LBRACE] = ACTIONS(5),
    [anon_sym_LBRACK] = ACTIONS(7),
    [sym_identifier] = ACTIONS(9),
    [anon_sym_DQUOTE] = ACTIONS(11),
    [sym_number] = ACTIONS(13),
    [sym_true] = ACTIONS(13),
    [sym_false] = ACTIONS(13),
    [sym_null] = ACTIONS(13),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 7,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    ACTIONS(15), 1,
      anon_sym_RBRACK,
    ACTIONS(17), 1,
      anon_sym_AT,
    ACTIONS(19), 4,
      sym_number,
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
  [30] = 7,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    ACTIONS(17), 1,
      anon_sym_AT,
    ACTIONS(21), 1,
      anon_sym_RBRACK,
    ACTIONS(23), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(30), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [60] = 7,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    ACTIONS(17), 1,
      anon_sym_AT,
    ACTIONS(25), 1,
      anon_sym_RBRACK,
    ACTIONS(19), 4,
      sym_number,
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
  [90] = 6,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    ACTIONS(17), 1,
      anon_sym_AT,
    ACTIONS(27), 4,
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
  [117] = 6,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    ACTIONS(17), 1,
      anon_sym_AT,
    ACTIONS(19), 4,
      sym_number,
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
  [144] = 6,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      anon_sym_LBRACK,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    ACTIONS(17), 1,
      anon_sym_AT,
    ACTIONS(29), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(34), 6,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
  [171] = 6,
    ACTIONS(9), 1,
      sym_identifier,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    ACTIONS(31), 1,
      anon_sym_RBRACE,
    STATE(42), 1,
      sym_struct_field,
    STATE(43), 1,
      sym_map_field,
    STATE(54), 1,
      sym_string,
  [190] = 1,
    ACTIONS(33), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_COLON,
      anon_sym_RPAREN,
  [199] = 1,
    ACTIONS(35), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_COLON,
      anon_sym_RPAREN,
  [208] = 4,
    ACTIONS(37), 1,
      anon_sym_DQUOTE,
    STATE(19), 1,
      aux_sym_string_content_repeat1,
    STATE(55), 1,
      sym_string_content,
    ACTIONS(39), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [222] = 4,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    ACTIONS(41), 1,
      anon_sym_RBRACE,
    STATE(53), 1,
      sym_map_field,
    STATE(54), 1,
      sym_string,
  [235] = 1,
    ACTIONS(43), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [242] = 1,
    ACTIONS(45), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [249] = 1,
    ACTIONS(47), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [256] = 1,
    ACTIONS(49), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [263] = 1,
    ACTIONS(51), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [270] = 1,
    ACTIONS(53), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [277] = 3,
    ACTIONS(55), 1,
      anon_sym_DQUOTE,
    STATE(21), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(57), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [288] = 3,
    ACTIONS(61), 1,
      anon_sym_COMMA,
    STATE(20), 1,
      aux_sym_top_level_struct_repeat1,
    ACTIONS(59), 2,
      ts_builtin_sym_end,
      anon_sym_RBRACE,
  [299] = 3,
    ACTIONS(64), 1,
      anon_sym_DQUOTE,
    STATE(21), 1,
      aux_sym_string_content_repeat1,
    ACTIONS(66), 2,
      aux_sym_string_content_token1,
      sym_escape_sequence,
  [310] = 1,
    ACTIONS(69), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [317] = 1,
    ACTIONS(71), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [324] = 1,
    ACTIONS(73), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [331] = 4,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    ACTIONS(75), 1,
      anon_sym_RBRACE,
    STATE(53), 1,
      sym_map_field,
    STATE(54), 1,
      sym_string,
  [344] = 1,
    ACTIONS(77), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [351] = 1,
    ACTIONS(79), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [358] = 1,
    ACTIONS(81), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
  [365] = 3,
    ACTIONS(83), 1,
      anon_sym_LPAREN,
    ACTIONS(85), 1,
      aux_sym_tag_token1,
    STATE(48), 1,
      aux_sym_tag_repeat1,
  [375] = 3,
    ACTIONS(87), 1,
      anon_sym_COMMA,
    ACTIONS(89), 1,
      anon_sym_RBRACK,
    STATE(33), 1,
      aux_sym_array_repeat1,
  [385] = 3,
    ACTIONS(91), 1,
      ts_builtin_sym_end,
    ACTIONS(93), 1,
      anon_sym_COMMA,
    STATE(39), 1,
      aux_sym_top_level_struct_repeat1,
  [395] = 3,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    STATE(53), 1,
      sym_map_field,
    STATE(54), 1,
      sym_string,
  [405] = 3,
    ACTIONS(15), 1,
      anon_sym_RBRACK,
    ACTIONS(95), 1,
      anon_sym_COMMA,
    STATE(46), 1,
      aux_sym_array_repeat1,
  [415] = 1,
    ACTIONS(97), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [421] = 3,
    ACTIONS(99), 1,
      anon_sym_COMMA,
    ACTIONS(101), 1,
      anon_sym_RBRACE,
    STATE(20), 1,
      aux_sym_top_level_struct_repeat1,
  [431] = 3,
    ACTIONS(9), 1,
      sym_identifier,
    ACTIONS(101), 1,
      anon_sym_RBRACE,
    STATE(37), 1,
      sym_struct_field,
  [441] = 1,
    ACTIONS(59), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [447] = 3,
    ACTIONS(9), 1,
      sym_identifier,
    ACTIONS(103), 1,
      ts_builtin_sym_end,
    STATE(37), 1,
      sym_struct_field,
  [457] = 3,
    ACTIONS(105), 1,
      ts_builtin_sym_end,
    ACTIONS(107), 1,
      anon_sym_COMMA,
    STATE(20), 1,
      aux_sym_top_level_struct_repeat1,
  [467] = 3,
    ACTIONS(9), 1,
      sym_identifier,
    ACTIONS(105), 1,
      ts_builtin_sym_end,
    STATE(37), 1,
      sym_struct_field,
  [477] = 3,
    ACTIONS(9), 1,
      sym_identifier,
    ACTIONS(109), 1,
      anon_sym_RBRACE,
    STATE(37), 1,
      sym_struct_field,
  [487] = 3,
    ACTIONS(111), 1,
      anon_sym_COMMA,
    ACTIONS(113), 1,
      anon_sym_RBRACE,
    STATE(35), 1,
      aux_sym_top_level_struct_repeat1,
  [497] = 3,
    ACTIONS(115), 1,
      anon_sym_COMMA,
    ACTIONS(117), 1,
      anon_sym_RBRACE,
    STATE(44), 1,
      aux_sym_map_repeat1,
  [507] = 3,
    ACTIONS(75), 1,
      anon_sym_RBRACE,
    ACTIONS(119), 1,
      anon_sym_COMMA,
    STATE(45), 1,
      aux_sym_map_repeat1,
  [517] = 3,
    ACTIONS(121), 1,
      anon_sym_COMMA,
    ACTIONS(124), 1,
      anon_sym_RBRACE,
    STATE(45), 1,
      aux_sym_map_repeat1,
  [527] = 3,
    ACTIONS(126), 1,
      anon_sym_COMMA,
    ACTIONS(129), 1,
      anon_sym_RBRACK,
    STATE(46), 1,
      aux_sym_array_repeat1,
  [537] = 3,
    ACTIONS(131), 1,
      aux_sym_tag_token1,
    STATE(29), 1,
      aux_sym_tag_repeat1,
    STATE(58), 1,
      sym_tag,
  [547] = 3,
    ACTIONS(133), 1,
      anon_sym_LPAREN,
    ACTIONS(135), 1,
      aux_sym_tag_token1,
    STATE(48), 1,
      aux_sym_tag_repeat1,
  [557] = 2,
    ACTIONS(11), 1,
      anon_sym_DQUOTE,
    STATE(57), 1,
      sym_string,
  [564] = 1,
    ACTIONS(129), 2,
      anon_sym_COMMA,
      anon_sym_RBRACK,
  [569] = 1,
    ACTIONS(138), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [574] = 2,
    ACTIONS(9), 1,
      sym_identifier,
    STATE(37), 1,
      sym_struct_field,
  [581] = 1,
    ACTIONS(124), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [586] = 1,
    ACTIONS(140), 1,
      anon_sym_COLON,
  [590] = 1,
    ACTIONS(142), 1,
      anon_sym_DQUOTE,
  [594] = 1,
    ACTIONS(144), 1,
      anon_sym_EQ,
  [598] = 1,
    ACTIONS(146), 1,
      anon_sym_RPAREN,
  [602] = 1,
    ACTIONS(148), 1,
      anon_sym_LPAREN,
  [606] = 1,
    ACTIONS(150), 1,
      ts_builtin_sym_end,
  [610] = 1,
    ACTIONS(152), 1,
      ts_builtin_sym_end,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(2)] = 0,
  [SMALL_STATE(3)] = 30,
  [SMALL_STATE(4)] = 60,
  [SMALL_STATE(5)] = 90,
  [SMALL_STATE(6)] = 117,
  [SMALL_STATE(7)] = 144,
  [SMALL_STATE(8)] = 171,
  [SMALL_STATE(9)] = 190,
  [SMALL_STATE(10)] = 199,
  [SMALL_STATE(11)] = 208,
  [SMALL_STATE(12)] = 222,
  [SMALL_STATE(13)] = 235,
  [SMALL_STATE(14)] = 242,
  [SMALL_STATE(15)] = 249,
  [SMALL_STATE(16)] = 256,
  [SMALL_STATE(17)] = 263,
  [SMALL_STATE(18)] = 270,
  [SMALL_STATE(19)] = 277,
  [SMALL_STATE(20)] = 288,
  [SMALL_STATE(21)] = 299,
  [SMALL_STATE(22)] = 310,
  [SMALL_STATE(23)] = 317,
  [SMALL_STATE(24)] = 324,
  [SMALL_STATE(25)] = 331,
  [SMALL_STATE(26)] = 344,
  [SMALL_STATE(27)] = 351,
  [SMALL_STATE(28)] = 358,
  [SMALL_STATE(29)] = 365,
  [SMALL_STATE(30)] = 375,
  [SMALL_STATE(31)] = 385,
  [SMALL_STATE(32)] = 395,
  [SMALL_STATE(33)] = 405,
  [SMALL_STATE(34)] = 415,
  [SMALL_STATE(35)] = 421,
  [SMALL_STATE(36)] = 431,
  [SMALL_STATE(37)] = 441,
  [SMALL_STATE(38)] = 447,
  [SMALL_STATE(39)] = 457,
  [SMALL_STATE(40)] = 467,
  [SMALL_STATE(41)] = 477,
  [SMALL_STATE(42)] = 487,
  [SMALL_STATE(43)] = 497,
  [SMALL_STATE(44)] = 507,
  [SMALL_STATE(45)] = 517,
  [SMALL_STATE(46)] = 527,
  [SMALL_STATE(47)] = 537,
  [SMALL_STATE(48)] = 547,
  [SMALL_STATE(49)] = 557,
  [SMALL_STATE(50)] = 564,
  [SMALL_STATE(51)] = 569,
  [SMALL_STATE(52)] = 574,
  [SMALL_STATE(53)] = 581,
  [SMALL_STATE(54)] = 586,
  [SMALL_STATE(55)] = 590,
  [SMALL_STATE(56)] = 594,
  [SMALL_STATE(57)] = 598,
  [SMALL_STATE(58)] = 602,
  [SMALL_STATE(59)] = 606,
  [SMALL_STATE(60)] = 610,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 0),
  [5] = {.entry = {.count = 1, .reusable = true}}, SHIFT(8),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [9] = {.entry = {.count = 1, .reusable = true}}, SHIFT(56),
  [11] = {.entry = {.count = 1, .reusable = true}}, SHIFT(11),
  [13] = {.entry = {.count = 1, .reusable = true}}, SHIFT(60),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(13),
  [17] = {.entry = {.count = 1, .reusable = true}}, SHIFT(47),
  [19] = {.entry = {.count = 1, .reusable = true}}, SHIFT(50),
  [21] = {.entry = {.count = 1, .reusable = true}}, SHIFT(14),
  [23] = {.entry = {.count = 1, .reusable = true}}, SHIFT(30),
  [25] = {.entry = {.count = 1, .reusable = true}}, SHIFT(28),
  [27] = {.entry = {.count = 1, .reusable = true}}, SHIFT(51),
  [29] = {.entry = {.count = 1, .reusable = true}}, SHIFT(34),
  [31] = {.entry = {.count = 1, .reusable = true}}, SHIFT(22),
  [33] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 3),
  [35] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 2),
  [37] = {.entry = {.count = 1, .reusable = false}}, SHIFT(10),
  [39] = {.entry = {.count = 1, .reusable = true}}, SHIFT(19),
  [41] = {.entry = {.count = 1, .reusable = true}}, SHIFT(27),
  [43] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 4),
  [45] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 2),
  [47] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 4),
  [49] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag_string, 5),
  [51] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5),
  [53] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4),
  [55] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_string_content, 1),
  [57] = {.entry = {.count = 1, .reusable = true}}, SHIFT(21),
  [59] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2),
  [61] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2), SHIFT_REPEAT(52),
  [64] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_string_content_repeat1, 2),
  [66] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_string_content_repeat1, 2), SHIFT_REPEAT(21),
  [69] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 2),
  [71] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3),
  [73] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [75] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [77] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 3),
  [79] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 5),
  [81] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 5),
  [83] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 1),
  [85] = {.entry = {.count = 1, .reusable = true}}, SHIFT(48),
  [87] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [89] = {.entry = {.count = 1, .reusable = true}}, SHIFT(24),
  [91] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 1),
  [93] = {.entry = {.count = 1, .reusable = true}}, SHIFT(40),
  [95] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [97] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 3, .production_id = 1),
  [99] = {.entry = {.count = 1, .reusable = true}}, SHIFT(41),
  [101] = {.entry = {.count = 1, .reusable = true}}, SHIFT(18),
  [103] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 3),
  [105] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 2),
  [107] = {.entry = {.count = 1, .reusable = true}}, SHIFT(38),
  [109] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [111] = {.entry = {.count = 1, .reusable = true}}, SHIFT(36),
  [113] = {.entry = {.count = 1, .reusable = true}}, SHIFT(23),
  [115] = {.entry = {.count = 1, .reusable = true}}, SHIFT(25),
  [117] = {.entry = {.count = 1, .reusable = true}}, SHIFT(26),
  [119] = {.entry = {.count = 1, .reusable = true}}, SHIFT(12),
  [121] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2), SHIFT_REPEAT(32),
  [124] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2),
  [126] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2), SHIFT_REPEAT(6),
  [129] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2),
  [131] = {.entry = {.count = 1, .reusable = true}}, SHIFT(29),
  [133] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2),
  [135] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2), SHIFT_REPEAT(48),
  [138] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map_field, 3, .production_id = 1),
  [140] = {.entry = {.count = 1, .reusable = true}}, SHIFT(5),
  [142] = {.entry = {.count = 1, .reusable = true}}, SHIFT(9),
  [144] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [146] = {.entry = {.count = 1, .reusable = true}}, SHIFT(16),
  [148] = {.entry = {.count = 1, .reusable = true}}, SHIFT(49),
  [150] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [152] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 1),
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
