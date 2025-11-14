#include "tree_sitter/parser.h"

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 14
#define STATE_COUNT 68
#define LARGE_STATE_COUNT 5
#define SYMBOL_COUNT 40
#define ALIAS_COUNT 1
#define TOKEN_COUNT 23
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 2
#define MAX_ALIAS_SEQUENCE_LENGTH 5
#define PRODUCTION_ID_COUNT 4

enum ts_symbol_identifiers {
  sym_identifier = 1,
  anon_sym_COMMA = 2,
  anon_sym_DOT_LBRACE = 3,
  anon_sym_RBRACE = 4,
  anon_sym_DOT = 5,
  anon_sym_EQ = 6,
  anon_sym_LBRACE = 7,
  anon_sym_COLON = 8,
  anon_sym_LBRACK = 9,
  anon_sym_RBRACK = 10,
  anon_sym_LPAREN = 11,
  anon_sym_RPAREN = 12,
  anon_sym_BSLASH_BSLASH = 13,
  aux_sym_line_string_token1 = 14,
  anon_sym_DQUOTE = 15,
  sym_string_content = 16,
  sym_escape_sequence = 17,
  sym_number = 18,
  sym_true = 19,
  sym_false = 20,
  sym_null = 21,
  sym_comment = 22,
  sym_document = 23,
  sym_value = 24,
  sym_top_level_struct = 25,
  sym_struct = 26,
  sym_struct_field = 27,
  sym_dict = 28,
  sym_dict_field = 29,
  sym_array = 30,
  sym_array_elem = 31,
  sym_union = 32,
  sym_enum = 33,
  sym_line_string = 34,
  sym_string = 35,
  aux_sym__string_content = 36,
  aux_sym_top_level_struct_repeat1 = 37,
  aux_sym_dict_repeat1 = 38,
  aux_sym_array_repeat1 = 39,
  anon_alias_sym__enum_name = 40,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [sym_identifier] = "identifier",
  [anon_sym_COMMA] = ",",
  [anon_sym_DOT_LBRACE] = ".{",
  [anon_sym_RBRACE] = "}",
  [anon_sym_DOT] = ".",
  [anon_sym_EQ] = "=",
  [anon_sym_LBRACE] = "{",
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
  [anon_sym_DOT_LBRACE] = anon_sym_DOT_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
  [anon_sym_DOT] = anon_sym_DOT,
  [anon_sym_EQ] = anon_sym_EQ,
  [anon_sym_LBRACE] = anon_sym_LBRACE,
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
  [anon_sym_DOT_LBRACE] = {
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
  [anon_sym_LBRACE] = {
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
    {field_key, 1},
    {field_value, 3},
  [2] =
    {field_key, 0},
    {field_value, 2},
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
  [66] = 66,
  [67] = 67,
};

static bool ts_lex(TSLexer *lexer, TSStateId state) {
  START_LEXER();
  eof = lexer->eof(lexer);
  switch (state) {
    case 0:
      if (eof) ADVANCE(13);
      if (lookahead == '"') ADVANCE(30);
      if (lookahead == '(') ADVANCE(23);
      if (lookahead == ')') ADVANCE(24);
      if (lookahead == ',') ADVANCE(14);
      if (lookahead == '-') ADVANCE(6);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '/') ADVANCE(5);
      if (lookahead == '0') ADVANCE(36);
      if (lookahead == ':') ADVANCE(20);
      if (lookahead == '=') ADVANCE(18);
      if (lookahead == '[') ADVANCE(21);
      if (lookahead == '\\') ADVANCE(8);
      if (lookahead == ']') ADVANCE(22);
      if (lookahead == '{') ADVANCE(19);
      if (lookahead == '}') ADVANCE(16);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(11)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(37);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(31);
      END_STATE();
    case 1:
      if (lookahead == '\n') ADVANCE(40);
      if (lookahead != 0) ADVANCE(1);
      END_STATE();
    case 2:
      if (lookahead == '\n') SKIP(3)
      if (lookahead == '"') ADVANCE(30);
      if (lookahead == '/') ADVANCE(33);
      if (lookahead == '\\') ADVANCE(9);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') ADVANCE(32);
      if (lookahead != 0) ADVANCE(34);
      END_STATE();
    case 3:
      if (lookahead == '"') ADVANCE(30);
      if (lookahead == '/') ADVANCE(5);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(3)
      END_STATE();
    case 4:
      if (lookahead == '-') ADVANCE(10);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(39);
      END_STATE();
    case 5:
      if (lookahead == '/') ADVANCE(1);
      END_STATE();
    case 6:
      if (lookahead == '0') ADVANCE(36);
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(37);
      END_STATE();
    case 7:
      if (lookahead == '\\') ADVANCE(25);
      END_STATE();
    case 8:
      if (lookahead == '"' ||
          lookahead == '/' ||
          lookahead == 'b' ||
          lookahead == 'f' ||
          lookahead == 'n' ||
          lookahead == 'r' ||
          lookahead == 't' ||
          lookahead == 'u') ADVANCE(35);
      if (lookahead == '\\') ADVANCE(25);
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
          lookahead == 'u') ADVANCE(35);
      END_STATE();
    case 10:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(39);
      END_STATE();
    case 11:
      if (eof) ADVANCE(13);
      if (lookahead == '"') ADVANCE(30);
      if (lookahead == '(') ADVANCE(23);
      if (lookahead == ')') ADVANCE(24);
      if (lookahead == ',') ADVANCE(14);
      if (lookahead == '-') ADVANCE(6);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '/') ADVANCE(5);
      if (lookahead == '0') ADVANCE(36);
      if (lookahead == ':') ADVANCE(20);
      if (lookahead == '=') ADVANCE(18);
      if (lookahead == '[') ADVANCE(21);
      if (lookahead == '\\') ADVANCE(7);
      if (lookahead == ']') ADVANCE(22);
      if (lookahead == '{') ADVANCE(19);
      if (lookahead == '}') ADVANCE(16);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(11)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(37);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(31);
      END_STATE();
    case 12:
      if (eof) ADVANCE(13);
      if (lookahead == '"') ADVANCE(30);
      if (lookahead == '-') ADVANCE(6);
      if (lookahead == '.') ADVANCE(17);
      if (lookahead == '/') ADVANCE(5);
      if (lookahead == '0') ADVANCE(36);
      if (lookahead == '[') ADVANCE(21);
      if (lookahead == '\\') ADVANCE(7);
      if (lookahead == ']') ADVANCE(22);
      if (lookahead == '{') ADVANCE(19);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(12)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(37);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(31);
      END_STATE();
    case 13:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 14:
      ACCEPT_TOKEN(anon_sym_COMMA);
      END_STATE();
    case 15:
      ACCEPT_TOKEN(anon_sym_DOT_LBRACE);
      END_STATE();
    case 16:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 17:
      ACCEPT_TOKEN(anon_sym_DOT);
      if (lookahead == '{') ADVANCE(15);
      END_STATE();
    case 18:
      ACCEPT_TOKEN(anon_sym_EQ);
      END_STATE();
    case 19:
      ACCEPT_TOKEN(anon_sym_LBRACE);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 21:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 22:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 23:
      ACCEPT_TOKEN(anon_sym_LPAREN);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(anon_sym_RPAREN);
      END_STATE();
    case 25:
      ACCEPT_TOKEN(anon_sym_BSLASH_BSLASH);
      END_STATE();
    case 26:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead == '\n') ADVANCE(40);
      if (lookahead != 0) ADVANCE(26);
      END_STATE();
    case 27:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead == '/') ADVANCE(28);
      if (lookahead == '\t' ||
          (11 <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') ADVANCE(27);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(29);
      END_STATE();
    case 28:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead == '/') ADVANCE(26);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(29);
      END_STATE();
    case 29:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(29);
      END_STATE();
    case 30:
      ACCEPT_TOKEN(anon_sym_DQUOTE);
      END_STATE();
    case 31:
      ACCEPT_TOKEN(sym_identifier);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(31);
      END_STATE();
    case 32:
      ACCEPT_TOKEN(sym_string_content);
      if (lookahead == '/') ADVANCE(33);
      if (lookahead == '\t' ||
          (11 <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') ADVANCE(32);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(34);
      END_STATE();
    case 33:
      ACCEPT_TOKEN(sym_string_content);
      if (lookahead == '/') ADVANCE(34);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(34);
      END_STATE();
    case 34:
      ACCEPT_TOKEN(sym_string_content);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(34);
      END_STATE();
    case 35:
      ACCEPT_TOKEN(sym_escape_sequence);
      END_STATE();
    case 36:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(38);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      END_STATE();
    case 37:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(38);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(37);
      END_STATE();
    case 38:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(4);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(38);
      END_STATE();
    case 39:
      ACCEPT_TOKEN(sym_number);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(39);
      END_STATE();
    case 40:
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
  [28] = {.lex_state = 2},
  [29] = {.lex_state = 0},
  [30] = {.lex_state = 2},
  [31] = {.lex_state = 2},
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
  [61] = {.lex_state = 0},
  [62] = {.lex_state = 0},
  [63] = {.lex_state = 0},
  [64] = {.lex_state = 0},
  [65] = {.lex_state = 0},
  [66] = {.lex_state = 27},
  [67] = {.lex_state = 0},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [sym_identifier] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
    [anon_sym_DOT_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
    [anon_sym_DOT] = ACTIONS(1),
    [anon_sym_EQ] = ACTIONS(1),
    [anon_sym_LBRACE] = ACTIONS(1),
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
    [sym_document] = STATE(64),
    [sym_value] = STATE(63),
    [sym_top_level_struct] = STATE(63),
    [sym_struct] = STATE(13),
    [sym_struct_field] = STATE(47),
    [sym_dict] = STATE(13),
    [sym_array] = STATE(13),
    [sym_union] = STATE(13),
    [sym_enum] = STATE(12),
    [sym_line_string] = STATE(13),
    [sym_string] = STATE(13),
    [ts_builtin_sym_end] = ACTIONS(5),
    [anon_sym_DOT_LBRACE] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(9),
    [anon_sym_LBRACE] = ACTIONS(11),
    [anon_sym_LBRACK] = ACTIONS(13),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(15),
    [anon_sym_DQUOTE] = ACTIONS(17),
    [sym_number] = ACTIONS(19),
    [sym_true] = ACTIONS(19),
    [sym_false] = ACTIONS(19),
    [sym_null] = ACTIONS(19),
    [sym_comment] = ACTIONS(3),
  },
  [2] = {
    [sym_value] = STATE(58),
    [sym_struct] = STATE(13),
    [sym_dict] = STATE(13),
    [sym_array] = STATE(13),
    [sym_array_elem] = STATE(44),
    [sym_union] = STATE(13),
    [sym_enum] = STATE(12),
    [sym_line_string] = STATE(13),
    [sym_string] = STATE(13),
    [anon_sym_DOT_LBRACE] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(21),
    [anon_sym_LBRACE] = ACTIONS(11),
    [anon_sym_LBRACK] = ACTIONS(13),
    [anon_sym_RBRACK] = ACTIONS(23),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(15),
    [anon_sym_DQUOTE] = ACTIONS(17),
    [sym_number] = ACTIONS(19),
    [sym_true] = ACTIONS(19),
    [sym_false] = ACTIONS(19),
    [sym_null] = ACTIONS(19),
    [sym_comment] = ACTIONS(3),
  },
  [3] = {
    [sym_value] = STATE(58),
    [sym_struct] = STATE(13),
    [sym_dict] = STATE(13),
    [sym_array] = STATE(13),
    [sym_array_elem] = STATE(56),
    [sym_union] = STATE(13),
    [sym_enum] = STATE(12),
    [sym_line_string] = STATE(13),
    [sym_string] = STATE(13),
    [anon_sym_DOT_LBRACE] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(21),
    [anon_sym_LBRACE] = ACTIONS(11),
    [anon_sym_LBRACK] = ACTIONS(13),
    [anon_sym_RBRACK] = ACTIONS(25),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(15),
    [anon_sym_DQUOTE] = ACTIONS(17),
    [sym_number] = ACTIONS(19),
    [sym_true] = ACTIONS(19),
    [sym_false] = ACTIONS(19),
    [sym_null] = ACTIONS(19),
    [sym_comment] = ACTIONS(3),
  },
  [4] = {
    [sym_value] = STATE(58),
    [sym_struct] = STATE(13),
    [sym_dict] = STATE(13),
    [sym_array] = STATE(13),
    [sym_array_elem] = STATE(56),
    [sym_union] = STATE(13),
    [sym_enum] = STATE(12),
    [sym_line_string] = STATE(13),
    [sym_string] = STATE(13),
    [anon_sym_DOT_LBRACE] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(21),
    [anon_sym_LBRACE] = ACTIONS(11),
    [anon_sym_LBRACK] = ACTIONS(13),
    [anon_sym_RBRACK] = ACTIONS(27),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(15),
    [anon_sym_DQUOTE] = ACTIONS(17),
    [sym_number] = ACTIONS(19),
    [sym_true] = ACTIONS(19),
    [sym_false] = ACTIONS(19),
    [sym_null] = ACTIONS(19),
    [sym_comment] = ACTIONS(3),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 12,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(11), 1,
      anon_sym_LBRACE,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_DOT,
    STATE(12), 1,
      sym_enum,
    STATE(56), 1,
      sym_array_elem,
    STATE(58), 1,
      sym_value,
    ACTIONS(19), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(13), 6,
      sym_struct,
      sym_dict,
      sym_array,
      sym_union,
      sym_line_string,
      sym_string,
  [45] = 11,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(11), 1,
      anon_sym_LBRACE,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_DOT,
    STATE(12), 1,
      sym_enum,
    STATE(51), 1,
      sym_value,
    ACTIONS(19), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(13), 6,
      sym_struct,
      sym_dict,
      sym_array,
      sym_union,
      sym_line_string,
      sym_string,
  [87] = 11,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(11), 1,
      anon_sym_LBRACE,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_DOT,
    STATE(12), 1,
      sym_enum,
    STATE(55), 1,
      sym_value,
    ACTIONS(19), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(13), 6,
      sym_struct,
      sym_dict,
      sym_array,
      sym_union,
      sym_line_string,
      sym_string,
  [129] = 11,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(7), 1,
      anon_sym_DOT_LBRACE,
    ACTIONS(11), 1,
      anon_sym_LBRACE,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(21), 1,
      anon_sym_DOT,
    STATE(12), 1,
      sym_enum,
    STATE(62), 1,
      sym_value,
    ACTIONS(19), 4,
      sym_number,
      sym_true,
      sym_false,
      sym_null,
    STATE(13), 6,
      sym_struct,
      sym_dict,
      sym_array,
      sym_union,
      sym_line_string,
      sym_string,
  [171] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(29), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_LPAREN,
      anon_sym_RPAREN,
  [183] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(31), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [195] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(33), 6,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [207] = 3,
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
  [221] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(35), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [232] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(39), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [243] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(41), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [254] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(43), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [265] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(45), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [276] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(47), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [287] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(49), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [298] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(51), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [309] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(53), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [320] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(55), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [331] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(57), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [342] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(59), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [353] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(61), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [364] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(63), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [375] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(65), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
  [386] = 4,
    ACTIONS(67), 1,
      anon_sym_DQUOTE,
    ACTIONS(71), 1,
      sym_comment,
    STATE(31), 1,
      aux_sym__string_content,
    ACTIONS(69), 2,
      sym_string_content,
      sym_escape_sequence,
  [400] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(73), 1,
      anon_sym_RBRACE,
    STATE(54), 1,
      sym_dict_field,
    STATE(59), 1,
      sym_string,
  [416] = 4,
    ACTIONS(71), 1,
      sym_comment,
    ACTIONS(75), 1,
      anon_sym_DQUOTE,
    STATE(28), 1,
      aux_sym__string_content,
    ACTIONS(77), 2,
      sym_string_content,
      sym_escape_sequence,
  [430] = 4,
    ACTIONS(71), 1,
      sym_comment,
    ACTIONS(79), 1,
      anon_sym_DQUOTE,
    STATE(31), 1,
      aux_sym__string_content,
    ACTIONS(81), 2,
      sym_string_content,
      sym_escape_sequence,
  [444] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(86), 1,
      anon_sym_COMMA,
    STATE(32), 1,
      aux_sym_top_level_struct_repeat1,
    ACTIONS(84), 2,
      ts_builtin_sym_end,
      anon_sym_RBRACE,
  [458] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(89), 1,
      anon_sym_RBRACE,
    STATE(54), 1,
      sym_dict_field,
    STATE(59), 1,
      sym_string,
  [474] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(91), 1,
      anon_sym_RBRACE,
    STATE(53), 1,
      sym_dict_field,
    STATE(59), 1,
      sym_string,
  [490] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(93), 1,
      anon_sym_EQ,
    ACTIONS(29), 2,
      ts_builtin_sym_end,
      anon_sym_LPAREN,
  [501] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(95), 1,
      anon_sym_COMMA,
    ACTIONS(98), 1,
      anon_sym_RBRACK,
    STATE(36), 1,
      aux_sym_array_repeat1,
  [514] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(73), 1,
      anon_sym_RBRACE,
    ACTIONS(100), 1,
      anon_sym_COMMA,
    STATE(52), 1,
      aux_sym_dict_repeat1,
  [527] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(102), 1,
      anon_sym_COMMA,
    ACTIONS(104), 1,
      anon_sym_RBRACE,
    STATE(32), 1,
      aux_sym_top_level_struct_repeat1,
  [540] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(104), 1,
      anon_sym_RBRACE,
    ACTIONS(106), 1,
      anon_sym_DOT,
    STATE(45), 1,
      sym_struct_field,
  [553] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    STATE(54), 1,
      sym_dict_field,
    STATE(59), 1,
      sym_string,
  [566] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(108), 1,
      ts_builtin_sym_end,
    ACTIONS(110), 1,
      anon_sym_COMMA,
    STATE(32), 1,
      aux_sym_top_level_struct_repeat1,
  [579] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(25), 1,
      anon_sym_RBRACK,
    ACTIONS(112), 1,
      anon_sym_COMMA,
    STATE(36), 1,
      aux_sym_array_repeat1,
  [592] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(106), 1,
      anon_sym_DOT,
    ACTIONS(108), 1,
      ts_builtin_sym_end,
    STATE(45), 1,
      sym_struct_field,
  [605] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(114), 1,
      anon_sym_COMMA,
    ACTIONS(116), 1,
      anon_sym_RBRACK,
    STATE(42), 1,
      aux_sym_array_repeat1,
  [618] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(84), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [627] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(106), 1,
      anon_sym_DOT,
    ACTIONS(118), 1,
      ts_builtin_sym_end,
    STATE(45), 1,
      sym_struct_field,
  [640] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(120), 1,
      ts_builtin_sym_end,
    ACTIONS(122), 1,
      anon_sym_COMMA,
    STATE(41), 1,
      aux_sym_top_level_struct_repeat1,
  [653] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(106), 1,
      anon_sym_DOT,
    ACTIONS(124), 1,
      anon_sym_RBRACE,
    STATE(49), 1,
      sym_struct_field,
  [666] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(126), 1,
      anon_sym_COMMA,
    ACTIONS(128), 1,
      anon_sym_RBRACE,
    STATE(38), 1,
      aux_sym_top_level_struct_repeat1,
  [679] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(106), 1,
      anon_sym_DOT,
    ACTIONS(130), 1,
      anon_sym_RBRACE,
    STATE(45), 1,
      sym_struct_field,
  [692] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(132), 3,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [701] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(134), 1,
      anon_sym_COMMA,
    ACTIONS(137), 1,
      anon_sym_RBRACE,
    STATE(52), 1,
      aux_sym_dict_repeat1,
  [714] = 4,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(139), 1,
      anon_sym_COMMA,
    ACTIONS(141), 1,
      anon_sym_RBRACE,
    STATE(37), 1,
      aux_sym_dict_repeat1,
  [727] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(137), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [735] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(143), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [743] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(98), 2,
      anon_sym_COMMA,
      anon_sym_RBRACK,
  [751] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(106), 1,
      anon_sym_DOT,
    STATE(45), 1,
      sym_struct_field,
  [761] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(145), 2,
      anon_sym_COMMA,
      anon_sym_RBRACK,
  [769] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(147), 1,
      anon_sym_COLON,
  [776] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(149), 1,
      sym_identifier,
  [783] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(151), 1,
      sym_identifier,
  [790] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(153), 1,
      anon_sym_RPAREN,
  [797] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(155), 1,
      ts_builtin_sym_end,
  [804] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(157), 1,
      ts_builtin_sym_end,
  [811] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(93), 1,
      anon_sym_EQ,
  [818] = 2,
    ACTIONS(71), 1,
      sym_comment,
    ACTIONS(159), 1,
      aux_sym_line_string_token1,
  [825] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(161), 1,
      sym_identifier,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(5)] = 0,
  [SMALL_STATE(6)] = 45,
  [SMALL_STATE(7)] = 87,
  [SMALL_STATE(8)] = 129,
  [SMALL_STATE(9)] = 171,
  [SMALL_STATE(10)] = 183,
  [SMALL_STATE(11)] = 195,
  [SMALL_STATE(12)] = 207,
  [SMALL_STATE(13)] = 221,
  [SMALL_STATE(14)] = 232,
  [SMALL_STATE(15)] = 243,
  [SMALL_STATE(16)] = 254,
  [SMALL_STATE(17)] = 265,
  [SMALL_STATE(18)] = 276,
  [SMALL_STATE(19)] = 287,
  [SMALL_STATE(20)] = 298,
  [SMALL_STATE(21)] = 309,
  [SMALL_STATE(22)] = 320,
  [SMALL_STATE(23)] = 331,
  [SMALL_STATE(24)] = 342,
  [SMALL_STATE(25)] = 353,
  [SMALL_STATE(26)] = 364,
  [SMALL_STATE(27)] = 375,
  [SMALL_STATE(28)] = 386,
  [SMALL_STATE(29)] = 400,
  [SMALL_STATE(30)] = 416,
  [SMALL_STATE(31)] = 430,
  [SMALL_STATE(32)] = 444,
  [SMALL_STATE(33)] = 458,
  [SMALL_STATE(34)] = 474,
  [SMALL_STATE(35)] = 490,
  [SMALL_STATE(36)] = 501,
  [SMALL_STATE(37)] = 514,
  [SMALL_STATE(38)] = 527,
  [SMALL_STATE(39)] = 540,
  [SMALL_STATE(40)] = 553,
  [SMALL_STATE(41)] = 566,
  [SMALL_STATE(42)] = 579,
  [SMALL_STATE(43)] = 592,
  [SMALL_STATE(44)] = 605,
  [SMALL_STATE(45)] = 618,
  [SMALL_STATE(46)] = 627,
  [SMALL_STATE(47)] = 640,
  [SMALL_STATE(48)] = 653,
  [SMALL_STATE(49)] = 666,
  [SMALL_STATE(50)] = 679,
  [SMALL_STATE(51)] = 692,
  [SMALL_STATE(52)] = 701,
  [SMALL_STATE(53)] = 714,
  [SMALL_STATE(54)] = 727,
  [SMALL_STATE(55)] = 735,
  [SMALL_STATE(56)] = 743,
  [SMALL_STATE(57)] = 751,
  [SMALL_STATE(58)] = 761,
  [SMALL_STATE(59)] = 769,
  [SMALL_STATE(60)] = 776,
  [SMALL_STATE(61)] = 783,
  [SMALL_STATE(62)] = 790,
  [SMALL_STATE(63)] = 797,
  [SMALL_STATE(64)] = 804,
  [SMALL_STATE(65)] = 811,
  [SMALL_STATE(66)] = 818,
  [SMALL_STATE(67)] = 825,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, SHIFT_EXTRA(),
  [5] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 0),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(48),
  [9] = {.entry = {.count = 1, .reusable = false}}, SHIFT(67),
  [11] = {.entry = {.count = 1, .reusable = true}}, SHIFT(34),
  [13] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(66),
  [17] = {.entry = {.count = 1, .reusable = true}}, SHIFT(30),
  [19] = {.entry = {.count = 1, .reusable = true}}, SHIFT(13),
  [21] = {.entry = {.count = 1, .reusable = false}}, SHIFT(60),
  [23] = {.entry = {.count = 1, .reusable = true}}, SHIFT(21),
  [25] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [27] = {.entry = {.count = 1, .reusable = true}}, SHIFT(23),
  [29] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_enum, 2, .production_id = 1),
  [31] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 2),
  [33] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 3),
  [35] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_value, 1),
  [37] = {.entry = {.count = 1, .reusable = true}}, SHIFT(8),
  [39] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_line_string, 2),
  [41] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 4),
  [43] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_dict, 3),
  [45] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_dict, 2),
  [47] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_dict, 4),
  [49] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4),
  [51] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3),
  [53] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 2),
  [55] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_dict, 5),
  [57] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 5),
  [59] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 2),
  [61] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_union, 4),
  [63] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5),
  [65] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [67] = {.entry = {.count = 1, .reusable = false}}, SHIFT(11),
  [69] = {.entry = {.count = 1, .reusable = true}}, SHIFT(31),
  [71] = {.entry = {.count = 1, .reusable = false}}, SHIFT_EXTRA(),
  [73] = {.entry = {.count = 1, .reusable = true}}, SHIFT(18),
  [75] = {.entry = {.count = 1, .reusable = false}}, SHIFT(10),
  [77] = {.entry = {.count = 1, .reusable = true}}, SHIFT(28),
  [79] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym__string_content, 2),
  [81] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym__string_content, 2), SHIFT_REPEAT(31),
  [84] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2),
  [86] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2), SHIFT_REPEAT(57),
  [89] = {.entry = {.count = 1, .reusable = true}}, SHIFT(22),
  [91] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [93] = {.entry = {.count = 1, .reusable = true}}, SHIFT(6),
  [95] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2), SHIFT_REPEAT(5),
  [98] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2),
  [100] = {.entry = {.count = 1, .reusable = true}}, SHIFT(33),
  [102] = {.entry = {.count = 1, .reusable = true}}, SHIFT(50),
  [104] = {.entry = {.count = 1, .reusable = true}}, SHIFT(19),
  [106] = {.entry = {.count = 1, .reusable = true}}, SHIFT(61),
  [108] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 2),
  [110] = {.entry = {.count = 1, .reusable = true}}, SHIFT(46),
  [112] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [114] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [116] = {.entry = {.count = 1, .reusable = true}}, SHIFT(27),
  [118] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 3),
  [120] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 1),
  [122] = {.entry = {.count = 1, .reusable = true}}, SHIFT(43),
  [124] = {.entry = {.count = 1, .reusable = true}}, SHIFT(24),
  [126] = {.entry = {.count = 1, .reusable = true}}, SHIFT(39),
  [128] = {.entry = {.count = 1, .reusable = true}}, SHIFT(20),
  [130] = {.entry = {.count = 1, .reusable = true}}, SHIFT(26),
  [132] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 4, .production_id = 2),
  [134] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_dict_repeat1, 2), SHIFT_REPEAT(40),
  [137] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_dict_repeat1, 2),
  [139] = {.entry = {.count = 1, .reusable = true}}, SHIFT(29),
  [141] = {.entry = {.count = 1, .reusable = true}}, SHIFT(16),
  [143] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_dict_field, 3, .production_id = 3),
  [145] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array_elem, 1),
  [147] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [149] = {.entry = {.count = 1, .reusable = true}}, SHIFT(9),
  [151] = {.entry = {.count = 1, .reusable = true}}, SHIFT(65),
  [153] = {.entry = {.count = 1, .reusable = true}}, SHIFT(25),
  [155] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 1),
  [157] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [159] = {.entry = {.count = 1, .reusable = false}}, SHIFT(14),
  [161] = {.entry = {.count = 1, .reusable = true}}, SHIFT(35),
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
