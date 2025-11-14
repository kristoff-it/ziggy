#include "tree_sitter/parser.h"

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 14
#define STATE_COUNT 66
#define LARGE_STATE_COUNT 5
#define SYMBOL_COUNT 39
#define ALIAS_COUNT 1
#define TOKEN_COUNT 22
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 2
#define MAX_ALIAS_SEQUENCE_LENGTH 5
#define PRODUCTION_ID_COUNT 4

enum ts_symbol_identifiers {
  sym_identifier = 1,
  anon_sym_COMMA = 2,
  anon_sym_LBRACE = 3,
  anon_sym_RBRACE = 4,
  anon_sym_DOT = 5,
  anon_sym_EQ = 6,
  anon_sym_COLON = 7,
  anon_sym_LBRACK = 8,
  anon_sym_RBRACK = 9,
  anon_sym_LPAREN = 10,
  anon_sym_RPAREN = 11,
  anon_sym_BSLASH_BSLASH = 12,
  aux_sym_line_string_token1 = 13,
  anon_sym_DQUOTE = 14,
  sym_string_content = 15,
  sym_escape_sequence = 16,
  sym_number = 17,
  sym_true = 18,
  sym_false = 19,
  sym_null = 20,
  sym_comment = 21,
  sym_document = 22,
  sym_value = 23,
  sym_top_level_struct = 24,
  sym_struct = 25,
  sym_struct_field = 26,
  sym_dict = 27,
  sym_dict_field = 28,
  sym_array = 29,
  sym_array_elem = 30,
  sym_union = 31,
  sym_enum = 32,
  sym_line_string = 33,
  sym_string = 34,
  aux_sym__string_content = 35,
  aux_sym_top_level_struct_repeat1 = 36,
  aux_sym_dict_repeat1 = 37,
  aux_sym_array_repeat1 = 38,
  anon_alias_sym__enum_name = 39,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [sym_identifier] = "identifier",
  [anon_sym_COMMA] = ",",
  [anon_sym_LBRACE] = "{",
  [anon_sym_RBRACE] = "}",
  [anon_sym_DOT] = ".",
  [anon_sym_EQ] = "=",
  [anon_sym_COLON] = ":",
  [anon_sym_LBRACK] = "[",
  [anon_sym_RBRACK] = "]",
  [anon_sym_LPAREN] = "(",
  [anon_sym_RPAREN] = ")",
  [anon_sym_BSLASH_BSLASH] = "\\\\",
  [aux_sym_line_string_token1] = "line_string_token1",
  [anon_sym_DQUOTE] = "\"",
  [sym_string_content] = "string_content",
  [sym_escape_sequence] = "escape_sequence",
  [sym_number] = "number",
  [sym_true] = "true",
  [sym_false] = "false",
  [sym_null] = "null",
  [sym_comment] = "comment",
  [sym_document] = "document",
  [sym_value] = "value",
  [sym_top_level_struct] = "top_level_struct",
  [sym_struct] = "struct",
  [sym_struct_field] = "struct_field",
  [sym_dict] = "dict",
  [sym_dict_field] = "dict_field",
  [sym_array] = "array",
  [sym_array_elem] = "array_elem",
  [sym_union] = "union",
  [sym_enum] = "enum",
  [sym_line_string] = "line_string",
  [sym_string] = "string",
  [aux_sym__string_content] = "_string_content",
  [aux_sym_top_level_struct_repeat1] = "top_level_struct_repeat1",
  [aux_sym_dict_repeat1] = "dict_repeat1",
  [aux_sym_array_repeat1] = "array_repeat1",
  [anon_alias_sym__enum_name] = "_enum_name",
};

static const TSSymbol ts_symbol_map[] = {
  [ts_builtin_sym_end] = ts_builtin_sym_end,
  [sym_identifier] = sym_identifier,
  [anon_sym_COMMA] = anon_sym_COMMA,
  [anon_sym_LBRACE] = anon_sym_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
  [anon_sym_DOT] = anon_sym_DOT,
  [anon_sym_EQ] = anon_sym_EQ,
  [anon_sym_COLON] = anon_sym_COLON,
  [anon_sym_LBRACK] = anon_sym_LBRACK,
  [anon_sym_RBRACK] = anon_sym_RBRACK,
  [anon_sym_LPAREN] = anon_sym_LPAREN,
  [anon_sym_RPAREN] = anon_sym_RPAREN,
  [anon_sym_BSLASH_BSLASH] = anon_sym_BSLASH_BSLASH,
  [aux_sym_line_string_token1] = aux_sym_line_string_token1,
  [anon_sym_DQUOTE] = anon_sym_DQUOTE,
  [sym_string_content] = sym_string_content,
  [sym_escape_sequence] = sym_escape_sequence,
  [sym_number] = sym_number,
  [sym_true] = sym_true,
  [sym_false] = sym_false,
  [sym_null] = sym_null,
  [sym_comment] = sym_comment,
  [sym_document] = sym_document,
  [sym_value] = sym_value,
  [sym_top_level_struct] = sym_top_level_struct,
  [sym_struct] = sym_struct,
  [sym_struct_field] = sym_struct_field,
  [sym_dict] = sym_dict,
  [sym_dict_field] = sym_dict_field,
  [sym_array] = sym_array,
  [sym_array_elem] = sym_array_elem,
  [sym_union] = sym_union,
  [sym_enum] = sym_enum,
  [sym_line_string] = sym_line_string,
  [sym_string] = sym_string,
  [aux_sym__string_content] = aux_sym__string_content,
  [aux_sym_top_level_struct_repeat1] = aux_sym_top_level_struct_repeat1,
  [aux_sym_dict_repeat1] = aux_sym_dict_repeat1,
  [aux_sym_array_repeat1] = aux_sym_array_repeat1,
  [anon_alias_sym__enum_name] = anon_alias_sym__enum_name,
};

static const TSSymbolMetadata ts_symbol_metadata[] = {
  [ts_builtin_sym_end] = {
    .visible = false,
    .named = true,
  },
  [sym_identifier] = {
    .visible = true,
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
  [anon_sym_LPAREN] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_RPAREN] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_BSLASH_BSLASH] = {
    .visible = true,
    .named = false,
  },
  [aux_sym_line_string_token1] = {
    .visible = false,
    .named = false,
  },
  [anon_sym_DQUOTE] = {
    .visible = true,
    .named = false,
  },
  [sym_string_content] = {
    .visible = true,
    .named = true,
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
  [sym_value] = {
    .visible = false,
    .named = true,
    .supertype = true,
  },
  [sym_top_level_struct] = {
    .visible = true,
    .named = true,
  },
  [sym_struct] = {
    .visible = true,
    .named = true,
  },
  [sym_struct_field] = {
    .visible = true,
    .named = true,
  },
  [sym_dict] = {
    .visible = true,
    .named = true,
  },
  [sym_dict_field] = {
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
  [sym_union] = {
    .visible = true,
    .named = true,
  },
  [sym_enum] = {
    .visible = true,
    .named = true,
  },
  [sym_line_string] = {
    .visible = true,
    .named = true,
  },
  [sym_string] = {
    .visible = true,
    .named = true,
  },
  [aux_sym__string_content] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_top_level_struct_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_dict_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_array_repeat1] = {
    .visible = false,
    .named = false,
  },
  [anon_alias_sym__enum_name] = {
    .visible = true,
    .named = false,
  },
};

enum ts_field_identifiers {
  field_key = 1,
  field_value = 2,
};

static const char * const ts_field_names[] = {
  [0] = NULL,
  [field_key] = "key",
  [field_value] = "value",
};

static const TSFieldMapSlice ts_field_map_slices[PRODUCTION_ID_COUNT] = {
  [2] = {.index = 0, .length = 2},
  [3] = {.index = 2, .length = 2},
};

static const TSFieldMapEntry ts_field_map_entries[] = {
  [0] =
    {field_key, 0},
    {field_value, 2},
  [2] =
    {field_key, 1},
    {field_value, 3},
};

static const TSSymbol ts_alias_sequences[PRODUCTION_ID_COUNT][MAX_ALIAS_SEQUENCE_LENGTH] = {
  [0] = {0},
  [1] = {
    [1] = anon_alias_sym__enum_name,
  },
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
  [63] = 63,
  [64] = 64,
  [65] = 65,
};

static bool ts_lex(TSLexer *lexer, TSStateId state) {
  START_LEXER();
  eof = lexer->eof(lexer);
  switch (state) {
    case 0:
      if (eof) ADVANCE(13);
      if (lookahead == '"') ADVANCE(29);
      if (lookahead == '(') ADVANCE(22);
      if (lookahead == ')') ADVANCE(23);
      if (lookahead == ',') ADVANCE(14);
      if (lookahead == '-') ADVANCE(6);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '/') ADVANCE(5);
      if (lookahead == '0') ADVANCE(35);
      if (lookahead == ':') ADVANCE(19);
      if (lookahead == '=') ADVANCE(18);
      if (lookahead == '[') ADVANCE(20);
      if (lookahead == '\\') ADVANCE(8);
      if (lookahead == ']') ADVANCE(21);
      if (lookahead == '{') ADVANCE(15);
      if (lookahead == '}') ADVANCE(16);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(11)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(36);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 1:
      if (lookahead == '\n') ADVANCE(39);
      if (lookahead != 0) ADVANCE(1);
      END_STATE();
    case 2:
      if (lookahead == '\n') SKIP(3)
      if (lookahead == '"') ADVANCE(29);
      if (lookahead == '/') ADVANCE(32);
      if (lookahead == '\\') ADVANCE(9);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') ADVANCE(31);
      if (lookahead != 0) ADVANCE(33);
      END_STATE();
    case 3:
      if (lookahead == '"') ADVANCE(29);
      if (lookahead == '/') ADVANCE(5);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(3)
      END_STATE();
    case 4:
      if (lookahead == '-') ADVANCE(10);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(38);
      END_STATE();
    case 5:
      if (lookahead == '/') ADVANCE(1);
      END_STATE();
    case 6:
      if (lookahead == '0') ADVANCE(35);
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(36);
      END_STATE();
    case 7:
      if (lookahead == '\\') ADVANCE(24);
      END_STATE();
    case 8:
      if (lookahead == '"' ||
          lookahead == '/' ||
          lookahead == 'b' ||
          lookahead == 'f' ||
          lookahead == 'n' ||
          lookahead == 'r' ||
          lookahead == 't' ||
          lookahead == 'u') ADVANCE(34);
      if (lookahead == '\\') ADVANCE(24);
      END_STATE();
    case 9:
      if (lookahead == '"' ||
          lookahead == '/' ||
          lookahead == '\\' ||
          lookahead == 'b' ||
          lookahead == 'f' ||
          lookahead == 'n' ||
          lookahead == 'r' ||
          lookahead == 't' ||
          lookahead == 'u') ADVANCE(34);
      END_STATE();
    case 10:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(38);
      END_STATE();
    case 11:
      if (eof) ADVANCE(13);
      if (lookahead == '"') ADVANCE(29);
      if (lookahead == '(') ADVANCE(22);
      if (lookahead == ')') ADVANCE(23);
      if (lookahead == ',') ADVANCE(14);
      if (lookahead == '-') ADVANCE(6);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '/') ADVANCE(5);
      if (lookahead == '0') ADVANCE(35);
      if (lookahead == ':') ADVANCE(19);
      if (lookahead == '=') ADVANCE(18);
      if (lookahead == '[') ADVANCE(20);
      if (lookahead == '\\') ADVANCE(7);
      if (lookahead == ']') ADVANCE(21);
      if (lookahead == '{') ADVANCE(15);
      if (lookahead == '}') ADVANCE(16);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(11)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(36);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 12:
      if (eof) ADVANCE(13);
      if (lookahead == '"') ADVANCE(29);
      if (lookahead == '-') ADVANCE(6);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '/') ADVANCE(5);
      if (lookahead == '0') ADVANCE(35);
      if (lookahead == '[') ADVANCE(20);
      if (lookahead == '\\') ADVANCE(7);
      if (lookahead == ']') ADVANCE(21);
      if (lookahead == '{') ADVANCE(15);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(12)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(36);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 13:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 14:
      ACCEPT_TOKEN(anon_sym_COMMA);
      END_STATE();
    case 15:
      ACCEPT_TOKEN(anon_sym_LBRACE);
      END_STATE();
    case 16:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 17:
      ACCEPT_TOKEN(anon_sym_DOT);
      END_STATE();
    case 18:
      ACCEPT_TOKEN(anon_sym_EQ);
      END_STATE();
    case 19:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 21:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 22:
      ACCEPT_TOKEN(anon_sym_LPAREN);
      END_STATE();
    case 23:
      ACCEPT_TOKEN(anon_sym_RPAREN);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(anon_sym_BSLASH_BSLASH);
      END_STATE();
    case 25:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead == '\n') ADVANCE(39);
      if (lookahead != 0) ADVANCE(25);
      END_STATE();
    case 26:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead == '/') ADVANCE(27);
      if (lookahead == '\t' ||
          (11 <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') ADVANCE(26);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(28);
      END_STATE();
    case 27:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead == '/') ADVANCE(25);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(28);
      END_STATE();
    case 28:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(28);
      END_STATE();
    case 29:
      ACCEPT_TOKEN(anon_sym_DQUOTE);
      END_STATE();
    case 30:
      ACCEPT_TOKEN(sym_identifier);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(30);
      END_STATE();
    case 31:
      ACCEPT_TOKEN(sym_string_content);
      if (lookahead == '/') ADVANCE(32);
      if (lookahead == '\t' ||
          (11 <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') ADVANCE(31);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(33);
      END_STATE();
    case 32:
      ACCEPT_TOKEN(sym_string_content);
      if (lookahead == '/') ADVANCE(33);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(33);
      END_STATE();
    case 33:
      ACCEPT_TOKEN(sym_string_content);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(33);
      END_STATE();
    case 34:
      ACCEPT_TOKEN(sym_escape_sequence);
      END_STATE();
    case 35:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(37);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      END_STATE();
    case 36:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(37);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(36);
      END_STATE();
    case 37:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(37);
      END_STATE();
    case 38:
      ACCEPT_TOKEN(sym_number);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(38);
      END_STATE();
    case 39:
      ACCEPT_TOKEN(sym_comment);
      END_STATE();
    default:
      return false;
  }
}

static bool ts_lex_keywords(TSLexer *lexer, TSStateId state) {
  START_LEXER();
  eof = lexer->eof(lexer);
  switch (state) {
    case 0:
      if (lookahead == 'f') ADVANCE(1);
      if (lookahead == 'n') ADVANCE(2);
      if (lookahead == 't') ADVANCE(3);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(0)
      END_STATE();
    case 1:
      if (lookahead == 'a') ADVANCE(4);
      END_STATE();
    case 2:
      if (lookahead == 'u') ADVANCE(5);
      END_STATE();
    case 3:
      if (lookahead == 'r') ADVANCE(6);
      END_STATE();
    case 4:
      if (lookahead == 'l') ADVANCE(7);
      END_STATE();
    case 5:
      if (lookahead == 'l') ADVANCE(8);
      END_STATE();
    case 6:
      if (lookahead == 'u') ADVANCE(9);
      END_STATE();
    case 7:
      if (lookahead == 's') ADVANCE(10);
      END_STATE();
    case 8:
      if (lookahead == 'l') ADVANCE(11);
      END_STATE();
    case 9:
      if (lookahead == 'e') ADVANCE(12);
      END_STATE();
    case 10:
      if (lookahead == 'e') ADVANCE(13);
      END_STATE();
    case 11:
      ACCEPT_TOKEN(sym_null);
      END_STATE();
    case 12:
      ACCEPT_TOKEN(sym_true);
      END_STATE();
    case 13:
      ACCEPT_TOKEN(sym_false);
      END_STATE();
    default:
      return false;
  }
}

static const TSLexMode ts_lex_modes[STATE_COUNT] = {
  [0] = {.lex_state = 0},
  [1] = {.lex_state = 12},
  [2] = {.lex_state = 12},
  [3] = {.lex_state = 12},
  [4] = {.lex_state = 12},
  [5] = {.lex_state = 12},
  [6] = {.lex_state = 12},
  [7] = {.lex_state = 12},
  [8] = {.lex_state = 12},
  [9] = {.lex_state = 0},
  [10] = {.lex_state = 0},
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
  [21] = {.lex_state = 0},
  [22] = {.lex_state = 0},
  [23] = {.lex_state = 0},
  [24] = {.lex_state = 0},
  [25] = {.lex_state = 0},
  [26] = {.lex_state = 0},
  [27] = {.lex_state = 0},
  [28] = {.lex_state = 0},
  [29] = {.lex_state = 2},
  [30] = {.lex_state = 0},
  [31] = {.lex_state = 2},
  [32] = {.lex_state = 0},
  [33] = {.lex_state = 2},
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
  [61] = {.lex_state = 0},
  [62] = {.lex_state = 0},
  [63] = {.lex_state = 0},
  [64] = {.lex_state = 0},
  [65] = {.lex_state = 26},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [sym_identifier] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
    [anon_sym_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
    [anon_sym_DOT] = ACTIONS(1),
    [anon_sym_EQ] = ACTIONS(1),
    [anon_sym_COLON] = ACTIONS(1),
    [anon_sym_LBRACK] = ACTIONS(1),
    [anon_sym_RBRACK] = ACTIONS(1),
    [anon_sym_LPAREN] = ACTIONS(1),
    [anon_sym_RPAREN] = ACTIONS(1),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(1),
    [anon_sym_DQUOTE] = ACTIONS(1),
    [sym_escape_sequence] = ACTIONS(1),
    [sym_number] = ACTIONS(1),
    [sym_true] = ACTIONS(1),
    [sym_false] = ACTIONS(1),
    [sym_null] = ACTIONS(1),
    [sym_comment] = ACTIONS(3),
  },
  [1] = {
    [sym_document] = STATE(63),
    [sym_value] = STATE(62),
    [sym_top_level_struct] = STATE(62),
    [sym_struct] = STATE(14),
    [sym_struct_field] = STATE(38),
    [sym_dict] = STATE(14),
    [sym_array] = STATE(14),
    [sym_union] = STATE(14),
    [sym_enum] = STATE(12),
    [sym_line_string] = STATE(14),
    [sym_string] = STATE(14),
    [ts_builtin_sym_end] = ACTIONS(5),
    [anon_sym_LBRACE] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(9),
    [anon_sym_LBRACK] = ACTIONS(11),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(13),
    [anon_sym_DQUOTE] = ACTIONS(15),
    [sym_number] = ACTIONS(17),
    [sym_true] = ACTIONS(17),
    [sym_false] = ACTIONS(17),
    [sym_null] = ACTIONS(17),
    [sym_comment] = ACTIONS(3),
  },
  [2] = {
    [sym_value] = STATE(56),
    [sym_struct] = STATE(14),
    [sym_dict] = STATE(14),
    [sym_array] = STATE(14),
    [sym_array_elem] = STATE(37),
    [sym_union] = STATE(14),
    [sym_enum] = STATE(12),
    [sym_line_string] = STATE(14),
    [sym_string] = STATE(14),
    [anon_sym_LBRACE] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(19),
    [anon_sym_LBRACK] = ACTIONS(11),
    [anon_sym_RBRACK] = ACTIONS(21),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(13),
    [anon_sym_DQUOTE] = ACTIONS(15),
    [sym_number] = ACTIONS(17),
    [sym_true] = ACTIONS(17),
    [sym_false] = ACTIONS(17),
    [sym_null] = ACTIONS(17),
    [sym_comment] = ACTIONS(3),
  },
  [3] = {
    [sym_value] = STATE(56),
    [sym_struct] = STATE(14),
    [sym_dict] = STATE(14),
    [sym_array] = STATE(14),
    [sym_array_elem] = STATE(52),
    [sym_union] = STATE(14),
    [sym_enum] = STATE(12),
    [sym_line_string] = STATE(14),
    [sym_string] = STATE(14),
    [anon_sym_LBRACE] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(19),
    [anon_sym_LBRACK] = ACTIONS(11),
    [anon_sym_RBRACK] = ACTIONS(23),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(13),
    [anon_sym_DQUOTE] = ACTIONS(15),
    [sym_number] = ACTIONS(17),
    [sym_true] = ACTIONS(17),
    [sym_false] = ACTIONS(17),
    [sym_null] = ACTIONS(17),
    [sym_comment] = ACTIONS(3),
  },
  [4] = {
    [sym_value] = STATE(56),
    [sym_struct] = STATE(14),
    [sym_dict] = STATE(14),
    [sym_array] = STATE(14),
    [sym_array_elem] = STATE(52),
    [sym_union] = STATE(14),
    [sym_enum] = STATE(12),
    [sym_line_string] = STATE(14),
    [sym_string] = STATE(14),
    [anon_sym_LBRACE] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(19),
    [anon_sym_LBRACK] = ACTIONS(11),
    [anon_sym_RBRACK] = ACTIONS(25),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(13),
    [anon_sym_DQUOTE] = ACTIONS(15),
    [sym_number] = ACTIONS(17),
    [sym_true] = ACTIONS(17),
    [sym_false] = ACTIONS(17),
    [sym_null] = ACTIONS(17),
    [sym_comment] = ACTIONS(3),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 11,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_DOT,
    STATE(12), 1,
      sym_enum,
    STATE(52), 1,
      sym_array_elem,
    STATE(56), 1,
      sym_value,
    ACTIONS(17), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(14), 6,
      sym_struct,
      sym_dict,
      sym_array,
      sym_union,
      sym_line_string,
      sym_string,
  [42] = 10,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_DOT,
    STATE(12), 1,
      sym_enum,
    STATE(60), 1,
      sym_value,
    ACTIONS(17), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(14), 6,
      sym_struct,
      sym_dict,
      sym_array,
      sym_union,
      sym_line_string,
      sym_string,
  [81] = 10,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_DOT,
    STATE(12), 1,
      sym_enum,
    STATE(53), 1,
      sym_value,
    ACTIONS(17), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(14), 6,
      sym_struct,
      sym_dict,
      sym_array,
      sym_union,
      sym_line_string,
      sym_string,
  [120] = 10,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_LBRACE,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(19), 1,
      anon_sym_DOT,
    STATE(12), 1,
      sym_enum,
    STATE(39), 1,
      sym_value,
    ACTIONS(17), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(14), 6,
      sym_struct,
      sym_dict,
      sym_array,
      sym_union,
      sym_line_string,
      sym_string,
  [159] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(27), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [171] = 7,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(29), 1,
      anon_sym_RBRACE,
    ACTIONS(31), 1,
      anon_sym_DOT,
    STATE(47), 1,
      sym_struct_field,
    STATE(49), 1,
      sym_dict_field,
    STATE(58), 1,
      sym_string,
  [193] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(33), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [205] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(37), 1,
      anon_sym_LPAREN,
    ACTIONS(35), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [219] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(39), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_LPAREN,
      anon_sym_RPAREN,
  [231] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(35), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [242] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(41), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [253] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(43), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [264] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(45), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [275] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(47), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [286] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(49), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [297] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(51), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [308] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(53), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [319] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(55), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [330] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(57), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [341] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(59), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [352] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(61), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [363] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(63), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [374] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(65), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [385] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(67), 1,
      anon_sym_RBRACE,
    STATE(54), 1,
      sym_dict_field,
    STATE(58), 1,
      sym_string,
  [401] = 4,
    ACTIONS(69), 1,
      anon_sym_DQUOTE,
    ACTIONS(73), 1,
      sym_comment,
    STATE(33), 1,
      aux_sym__string_content,
    ACTIONS(71), 2,
      sym_string_content,
      sym_escape_sequence,
  [415] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    ACTIONS(75), 1,
      anon_sym_RBRACE,
    STATE(54), 1,
      sym_dict_field,
    STATE(58), 1,
      sym_string,
  [431] = 4,
    ACTIONS(73), 1,
      sym_comment,
    ACTIONS(77), 1,
      anon_sym_DQUOTE,
    STATE(29), 1,
      aux_sym__string_content,
    ACTIONS(79), 2,
      sym_string_content,
      sym_escape_sequence,
  [445] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(83), 1,
      anon_sym_COMMA,
    STATE(32), 1,
      aux_sym_top_level_struct_repeat1,
    ACTIONS(81), 2,
      ts_builtin_sym_end,
      anon_sym_RBRACE,
  [459] = 4,
    ACTIONS(73), 1,
      sym_comment,
    ACTIONS(86), 1,
      anon_sym_DQUOTE,
    STATE(33), 1,
      aux_sym__string_content,
    ACTIONS(88), 2,
      sym_string_content,
      sym_escape_sequence,
  [473] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(91), 1,
      anon_sym_COMMA,
    ACTIONS(94), 1,
      anon_sym_RBRACK,
    STATE(34), 1,
      aux_sym_array_repeat1,
  [486] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(67), 1,
      anon_sym_RBRACE,
    ACTIONS(96), 1,
      anon_sym_COMMA,
    STATE(51), 1,
      aux_sym_dict_repeat1,
  [499] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(15), 1,
      anon_sym_DQUOTE,
    STATE(54), 1,
      sym_dict_field,
    STATE(58), 1,
      sym_string,
  [512] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(98), 1,
      anon_sym_COMMA,
    ACTIONS(100), 1,
      anon_sym_RBRACK,
    STATE(40), 1,
      aux_sym_array_repeat1,
  [525] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(102), 1,
      ts_builtin_sym_end,
    ACTIONS(104), 1,
      anon_sym_COMMA,
    STATE(42), 1,
      aux_sym_top_level_struct_repeat1,
  [538] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(106), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [547] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(25), 1,
      anon_sym_RBRACK,
    ACTIONS(108), 1,
      anon_sym_COMMA,
    STATE(34), 1,
      aux_sym_array_repeat1,
  [560] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(110), 1,
      anon_sym_EQ,
    ACTIONS(39), 2,
      ts_builtin_sym_end,
      anon_sym_LPAREN,
  [571] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(112), 1,
      ts_builtin_sym_end,
    ACTIONS(114), 1,
      anon_sym_COMMA,
    STATE(32), 1,
      aux_sym_top_level_struct_repeat1,
  [584] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(81), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [593] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(31), 1,
      anon_sym_DOT,
    ACTIONS(116), 1,
      ts_builtin_sym_end,
    STATE(43), 1,
      sym_struct_field,
  [606] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(118), 1,
      anon_sym_COMMA,
    ACTIONS(120), 1,
      anon_sym_RBRACE,
    STATE(32), 1,
      aux_sym_top_level_struct_repeat1,
  [619] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(31), 1,
      anon_sym_DOT,
    ACTIONS(112), 1,
      ts_builtin_sym_end,
    STATE(43), 1,
      sym_struct_field,
  [632] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(122), 1,
      anon_sym_COMMA,
    ACTIONS(124), 1,
      anon_sym_RBRACE,
    STATE(45), 1,
      aux_sym_top_level_struct_repeat1,
  [645] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(31), 1,
      anon_sym_DOT,
    ACTIONS(126), 1,
      anon_sym_RBRACE,
    STATE(43), 1,
      sym_struct_field,
  [658] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(128), 1,
      anon_sym_COMMA,
    ACTIONS(130), 1,
      anon_sym_RBRACE,
    STATE(35), 1,
      aux_sym_dict_repeat1,
  [671] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(31), 1,
      anon_sym_DOT,
    ACTIONS(120), 1,
      anon_sym_RBRACE,
    STATE(43), 1,
      sym_struct_field,
  [684] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(132), 1,
      anon_sym_COMMA,
    ACTIONS(135), 1,
      anon_sym_RBRACE,
    STATE(51), 1,
      aux_sym_dict_repeat1,
  [697] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(94), 2,
      anon_sym_COMMA,
      anon_sym_RBRACK,
  [705] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(137), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [713] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(135), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [721] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(31), 1,
      anon_sym_DOT,
    STATE(43), 1,
      sym_struct_field,
  [731] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(139), 2,
      anon_sym_COMMA,
      anon_sym_RBRACK,
  [739] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(110), 1,
      anon_sym_EQ,
  [746] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(141), 1,
      anon_sym_COLON,
  [753] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(143), 1,
      sym_identifier,
  [760] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(145), 1,
      anon_sym_RPAREN,
  [767] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(147), 1,
      sym_identifier,
  [774] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(149), 1,
      ts_builtin_sym_end,
  [781] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(151), 1,
      ts_builtin_sym_end,
  [788] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(153), 1,
      sym_identifier,
  [795] = 2,
    ACTIONS(73), 1,
      sym_comment,
    ACTIONS(155), 1,
      aux_sym_line_string_token1,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(5)] = 0,
  [SMALL_STATE(6)] = 42,
  [SMALL_STATE(7)] = 81,
  [SMALL_STATE(8)] = 120,
  [SMALL_STATE(9)] = 159,
  [SMALL_STATE(10)] = 171,
  [SMALL_STATE(11)] = 193,
  [SMALL_STATE(12)] = 205,
  [SMALL_STATE(13)] = 219,
  [SMALL_STATE(14)] = 231,
  [SMALL_STATE(15)] = 242,
  [SMALL_STATE(16)] = 253,
  [SMALL_STATE(17)] = 264,
  [SMALL_STATE(18)] = 275,
  [SMALL_STATE(19)] = 286,
  [SMALL_STATE(20)] = 297,
  [SMALL_STATE(21)] = 308,
  [SMALL_STATE(22)] = 319,
  [SMALL_STATE(23)] = 330,
  [SMALL_STATE(24)] = 341,
  [SMALL_STATE(25)] = 352,
  [SMALL_STATE(26)] = 363,
  [SMALL_STATE(27)] = 374,
  [SMALL_STATE(28)] = 385,
  [SMALL_STATE(29)] = 401,
  [SMALL_STATE(30)] = 415,
  [SMALL_STATE(31)] = 431,
  [SMALL_STATE(32)] = 445,
  [SMALL_STATE(33)] = 459,
  [SMALL_STATE(34)] = 473,
  [SMALL_STATE(35)] = 486,
  [SMALL_STATE(36)] = 499,
  [SMALL_STATE(37)] = 512,
  [SMALL_STATE(38)] = 525,
  [SMALL_STATE(39)] = 538,
  [SMALL_STATE(40)] = 547,
  [SMALL_STATE(41)] = 560,
  [SMALL_STATE(42)] = 571,
  [SMALL_STATE(43)] = 584,
  [SMALL_STATE(44)] = 593,
  [SMALL_STATE(45)] = 606,
  [SMALL_STATE(46)] = 619,
  [SMALL_STATE(47)] = 632,
  [SMALL_STATE(48)] = 645,
  [SMALL_STATE(49)] = 658,
  [SMALL_STATE(50)] = 671,
  [SMALL_STATE(51)] = 684,
  [SMALL_STATE(52)] = 697,
  [SMALL_STATE(53)] = 705,
  [SMALL_STATE(54)] = 713,
  [SMALL_STATE(55)] = 721,
  [SMALL_STATE(56)] = 731,
  [SMALL_STATE(57)] = 739,
  [SMALL_STATE(58)] = 746,
  [SMALL_STATE(59)] = 753,
  [SMALL_STATE(60)] = 760,
  [SMALL_STATE(61)] = 767,
  [SMALL_STATE(62)] = 774,
  [SMALL_STATE(63)] = 781,
  [SMALL_STATE(64)] = 788,
  [SMALL_STATE(65)] = 795,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, SHIFT_EXTRA(),
  [5] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 0),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(10),
  [9] = {.entry = {.count = 1, .reusable = true}}, SHIFT(64),
  [11] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [13] = {.entry = {.count = 1, .reusable = true}}, SHIFT(65),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(31),
  [17] = {.entry = {.count = 1, .reusable = true}}, SHIFT(14),
  [19] = {.entry = {.count = 1, .reusable = true}}, SHIFT(61),
  [21] = {.entry = {.count = 1, .reusable = true}}, SHIFT(19),
  [23] = {.entry = {.count = 1, .reusable = true}}, SHIFT(16),
  [25] = {.entry = {.count = 1, .reusable = true}}, SHIFT(20),
  [27] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 3),
  [29] = {.entry = {.count = 1, .reusable = true}}, SHIFT(21),
  [31] = {.entry = {.count = 1, .reusable = true}}, SHIFT(59),
  [33] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 2),
  [35] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_value, 1),
  [37] = {.entry = {.count = 1, .reusable = true}}, SHIFT(6),
  [39] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_enum, 2, .production_id = 1),
  [41] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4),
  [43] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 5),
  [45] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [47] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_dict, 4),
  [49] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 2),
  [51] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 4),
  [53] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 2),
  [55] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_line_string, 2),
  [57] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_union, 4),
  [59] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5),
  [61] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_dict, 3),
  [63] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3),
  [65] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_dict, 5),
  [67] = {.entry = {.count = 1, .reusable = true}}, SHIFT(18),
  [69] = {.entry = {.count = 1, .reusable = false}}, SHIFT(9),
  [71] = {.entry = {.count = 1, .reusable = true}}, SHIFT(33),
  [73] = {.entry = {.count = 1, .reusable = false}}, SHIFT_EXTRA(),
  [75] = {.entry = {.count = 1, .reusable = true}}, SHIFT(27),
  [77] = {.entry = {.count = 1, .reusable = false}}, SHIFT(11),
  [79] = {.entry = {.count = 1, .reusable = true}}, SHIFT(29),
  [81] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2),
  [83] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2), SHIFT_REPEAT(55),
  [86] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym__string_content, 2),
  [88] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym__string_content, 2), SHIFT_REPEAT(33),
  [91] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2), SHIFT_REPEAT(5),
  [94] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2),
  [96] = {.entry = {.count = 1, .reusable = true}}, SHIFT(30),
  [98] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [100] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [102] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 1),
  [104] = {.entry = {.count = 1, .reusable = true}}, SHIFT(46),
  [106] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 4, .production_id = 3),
  [108] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [110] = {.entry = {.count = 1, .reusable = true}}, SHIFT(8),
  [112] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 2),
  [114] = {.entry = {.count = 1, .reusable = true}}, SHIFT(44),
  [116] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 3),
  [118] = {.entry = {.count = 1, .reusable = true}}, SHIFT(48),
  [120] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [122] = {.entry = {.count = 1, .reusable = true}}, SHIFT(50),
  [124] = {.entry = {.count = 1, .reusable = true}}, SHIFT(26),
  [126] = {.entry = {.count = 1, .reusable = true}}, SHIFT(24),
  [128] = {.entry = {.count = 1, .reusable = true}}, SHIFT(28),
  [130] = {.entry = {.count = 1, .reusable = true}}, SHIFT(25),
  [132] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_dict_repeat1, 2), SHIFT_REPEAT(36),
  [135] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_dict_repeat1, 2),
  [137] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_dict_field, 3, .production_id = 2),
  [139] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array_elem, 1),
  [141] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [143] = {.entry = {.count = 1, .reusable = true}}, SHIFT(57),
  [145] = {.entry = {.count = 1, .reusable = true}}, SHIFT(23),
  [147] = {.entry = {.count = 1, .reusable = true}}, SHIFT(13),
  [149] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 1),
  [151] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [153] = {.entry = {.count = 1, .reusable = true}}, SHIFT(41),
  [155] = {.entry = {.count = 1, .reusable = false}}, SHIFT(22),
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
    .keyword_lex_fn = ts_lex_keywords,
    .keyword_capture_token = sym_identifier,
    .primary_state_ids = ts_primary_state_ids,
  };
  return &language;
}
#ifdef __cplusplus
}
#endif
