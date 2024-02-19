#include <tree_sitter/parser.h>

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 13
#define STATE_COUNT 126
#define LARGE_STATE_COUNT 6
#define SYMBOL_COUNT 64
#define ALIAS_COUNT 0
#define TOKEN_COUNT 37
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 3
#define MAX_ALIAS_SEQUENCE_LENGTH 7
#define PRODUCTION_ID_COUNT 6

enum {
  anon_sym_COMMA = 1,
  anon_sym_LBRACE = 2,
  anon_sym_RBRACE = 3,
  aux_sym_struct_name_token1 = 4,
  aux_sym_struct_name_token2 = 5,
  anon_sym_DOT = 6,
  anon_sym_EQ = 7,
  anon_sym_COLON = 8,
  anon_sym_LBRACK = 9,
  anon_sym_RBRACK = 10,
  anon_sym_AT = 11,
  anon_sym_LPAREN = 12,
  anon_sym_RPAREN = 13,
  aux_sym_tag_token1 = 14,
  aux_sym_tag_token2 = 15,
  anon_sym_BSLASH_BSLASH = 16,
  aux_sym_line_string_token1 = 17,
  anon_sym_DQUOTE = 18,
  aux_sym_quoted_string_token1 = 19,
  anon_sym_BSLASH = 20,
  aux_sym_escape_sequence_token1 = 21,
  aux_sym_escape_sequence_token2 = 22,
  aux_sym_escape_sequence_token3 = 23,
  sym_identifier = 24,
  aux_sym_float_token1 = 25,
  aux_sym_float_token2 = 26,
  aux_sym_float_token3 = 27,
  aux_sym_float_token4 = 28,
  aux_sym_integer_token1 = 29,
  aux_sym_integer_token2 = 30,
  aux_sym_integer_token3 = 31,
  aux_sym_integer_token4 = 32,
  sym_true = 33,
  sym_false = 34,
  sym_null = 35,
  aux_sym_comment_token1 = 36,
  sym_document = 37,
  sym__value = 38,
  sym_top_level_struct = 39,
  sym_struct = 40,
  sym_struct_name = 41,
  sym_struct_field = 42,
  sym_map = 43,
  sym_map_field = 44,
  sym_array = 45,
  sym_array_elem = 46,
  sym_tag_string = 47,
  sym_tag = 48,
  sym_string = 49,
  sym_line_string = 50,
  sym_quoted_string = 51,
  sym_escape_sequence = 52,
  sym_float = 53,
  sym_integer = 54,
  sym_comment = 55,
  aux_sym_top_level_struct_repeat1 = 56,
  aux_sym_struct_name_repeat1 = 57,
  aux_sym_map_repeat1 = 58,
  aux_sym_array_repeat1 = 59,
  aux_sym_tag_repeat1 = 60,
  aux_sym_string_repeat1 = 61,
  aux_sym_quoted_string_repeat1 = 62,
  aux_sym_comment_repeat1 = 63,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [anon_sym_COMMA] = ",",
  [anon_sym_LBRACE] = "{",
  [anon_sym_RBRACE] = "}",
  [aux_sym_struct_name_token1] = "struct_name_token1",
  [aux_sym_struct_name_token2] = "struct_name_token2",
  [anon_sym_DOT] = ".",
  [anon_sym_EQ] = "=",
  [anon_sym_COLON] = ":",
  [anon_sym_LBRACK] = "[",
  [anon_sym_RBRACK] = "]",
  [anon_sym_AT] = "@",
  [anon_sym_LPAREN] = "(",
  [anon_sym_RPAREN] = ")",
  [aux_sym_tag_token1] = "tag_token1",
  [aux_sym_tag_token2] = "tag_token2",
  [anon_sym_BSLASH_BSLASH] = "\\\\",
  [aux_sym_line_string_token1] = "line_string_token1",
  [anon_sym_DQUOTE] = "\"",
  [aux_sym_quoted_string_token1] = "quoted_string_token1",
  [anon_sym_BSLASH] = "\\",
  [aux_sym_escape_sequence_token1] = "escape_sequence_token1",
  [aux_sym_escape_sequence_token2] = "escape_sequence_token2",
  [aux_sym_escape_sequence_token3] = "escape_sequence_token3",
  [sym_identifier] = "identifier",
  [aux_sym_float_token1] = "float_token1",
  [aux_sym_float_token2] = "float_token2",
  [aux_sym_float_token3] = "float_token3",
  [aux_sym_float_token4] = "float_token4",
  [aux_sym_integer_token1] = "integer_token1",
  [aux_sym_integer_token2] = "integer_token2",
  [aux_sym_integer_token3] = "integer_token3",
  [aux_sym_integer_token4] = "integer_token4",
  [sym_true] = "true",
  [sym_false] = "false",
  [sym_null] = "null",
  [aux_sym_comment_token1] = "comment_token1",
  [sym_document] = "document",
  [sym__value] = "_value",
  [sym_top_level_struct] = "top_level_struct",
  [sym_struct] = "struct",
  [sym_struct_name] = "struct_name",
  [sym_struct_field] = "struct_field",
  [sym_map] = "map",
  [sym_map_field] = "map_field",
  [sym_array] = "array",
  [sym_array_elem] = "array_elem",
  [sym_tag_string] = "tag_string",
  [sym_tag] = "tag",
  [sym_string] = "string",
  [sym_line_string] = "line_string",
  [sym_quoted_string] = "quoted_string",
  [sym_escape_sequence] = "escape_sequence",
  [sym_float] = "float",
  [sym_integer] = "integer",
  [sym_comment] = "comment",
  [aux_sym_top_level_struct_repeat1] = "top_level_struct_repeat1",
  [aux_sym_struct_name_repeat1] = "struct_name_repeat1",
  [aux_sym_map_repeat1] = "map_repeat1",
  [aux_sym_array_repeat1] = "array_repeat1",
  [aux_sym_tag_repeat1] = "tag_repeat1",
  [aux_sym_string_repeat1] = "string_repeat1",
  [aux_sym_quoted_string_repeat1] = "quoted_string_repeat1",
  [aux_sym_comment_repeat1] = "comment_repeat1",
};

static const TSSymbol ts_symbol_map[] = {
  [ts_builtin_sym_end] = ts_builtin_sym_end,
  [anon_sym_COMMA] = anon_sym_COMMA,
  [anon_sym_LBRACE] = anon_sym_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
  [aux_sym_struct_name_token1] = aux_sym_struct_name_token1,
  [aux_sym_struct_name_token2] = aux_sym_struct_name_token2,
  [anon_sym_DOT] = anon_sym_DOT,
  [anon_sym_EQ] = anon_sym_EQ,
  [anon_sym_COLON] = anon_sym_COLON,
  [anon_sym_LBRACK] = anon_sym_LBRACK,
  [anon_sym_RBRACK] = anon_sym_RBRACK,
  [anon_sym_AT] = anon_sym_AT,
  [anon_sym_LPAREN] = anon_sym_LPAREN,
  [anon_sym_RPAREN] = anon_sym_RPAREN,
  [aux_sym_tag_token1] = aux_sym_tag_token1,
  [aux_sym_tag_token2] = aux_sym_tag_token2,
  [anon_sym_BSLASH_BSLASH] = anon_sym_BSLASH_BSLASH,
  [aux_sym_line_string_token1] = aux_sym_line_string_token1,
  [anon_sym_DQUOTE] = anon_sym_DQUOTE,
  [aux_sym_quoted_string_token1] = aux_sym_quoted_string_token1,
  [anon_sym_BSLASH] = anon_sym_BSLASH,
  [aux_sym_escape_sequence_token1] = aux_sym_escape_sequence_token1,
  [aux_sym_escape_sequence_token2] = aux_sym_escape_sequence_token2,
  [aux_sym_escape_sequence_token3] = aux_sym_escape_sequence_token3,
  [sym_identifier] = sym_identifier,
  [aux_sym_float_token1] = aux_sym_float_token1,
  [aux_sym_float_token2] = aux_sym_float_token2,
  [aux_sym_float_token3] = aux_sym_float_token3,
  [aux_sym_float_token4] = aux_sym_float_token4,
  [aux_sym_integer_token1] = aux_sym_integer_token1,
  [aux_sym_integer_token2] = aux_sym_integer_token2,
  [aux_sym_integer_token3] = aux_sym_integer_token3,
  [aux_sym_integer_token4] = aux_sym_integer_token4,
  [sym_true] = sym_true,
  [sym_false] = sym_false,
  [sym_null] = sym_null,
  [aux_sym_comment_token1] = aux_sym_comment_token1,
  [sym_document] = sym_document,
  [sym__value] = sym__value,
  [sym_top_level_struct] = sym_top_level_struct,
  [sym_struct] = sym_struct,
  [sym_struct_name] = sym_struct_name,
  [sym_struct_field] = sym_struct_field,
  [sym_map] = sym_map,
  [sym_map_field] = sym_map_field,
  [sym_array] = sym_array,
  [sym_array_elem] = sym_array_elem,
  [sym_tag_string] = sym_tag_string,
  [sym_tag] = sym_tag,
  [sym_string] = sym_string,
  [sym_line_string] = sym_line_string,
  [sym_quoted_string] = sym_quoted_string,
  [sym_escape_sequence] = sym_escape_sequence,
  [sym_float] = sym_float,
  [sym_integer] = sym_integer,
  [sym_comment] = sym_comment,
  [aux_sym_top_level_struct_repeat1] = aux_sym_top_level_struct_repeat1,
  [aux_sym_struct_name_repeat1] = aux_sym_struct_name_repeat1,
  [aux_sym_map_repeat1] = aux_sym_map_repeat1,
  [aux_sym_array_repeat1] = aux_sym_array_repeat1,
  [aux_sym_tag_repeat1] = aux_sym_tag_repeat1,
  [aux_sym_string_repeat1] = aux_sym_string_repeat1,
  [aux_sym_quoted_string_repeat1] = aux_sym_quoted_string_repeat1,
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
  [aux_sym_struct_name_token1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_struct_name_token2] = {
    .visible = false,
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
  [aux_sym_tag_token2] = {
    .visible = false,
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
  [aux_sym_quoted_string_token1] = {
    .visible = false,
    .named = false,
  },
  [anon_sym_BSLASH] = {
    .visible = true,
    .named = false,
  },
  [aux_sym_escape_sequence_token1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_escape_sequence_token2] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_escape_sequence_token3] = {
    .visible = false,
    .named = false,
  },
  [sym_identifier] = {
    .visible = true,
    .named = true,
  },
  [aux_sym_float_token1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_float_token2] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_float_token3] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_float_token4] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_integer_token1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_integer_token2] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_integer_token3] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_integer_token4] = {
    .visible = false,
    .named = false,
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
  [sym_struct_name] = {
    .visible = true,
    .named = true,
  },
  [sym_struct_field] = {
    .visible = true,
    .named = true,
  },
  [sym_map] = {
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
  [sym_line_string] = {
    .visible = true,
    .named = true,
  },
  [sym_quoted_string] = {
    .visible = true,
    .named = true,
  },
  [sym_escape_sequence] = {
    .visible = true,
    .named = true,
  },
  [sym_float] = {
    .visible = true,
    .named = true,
  },
  [sym_integer] = {
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
  [aux_sym_struct_name_repeat1] = {
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
  [aux_sym_string_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_quoted_string_repeat1] = {
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
      if (eof) ADVANCE(40);
      if (lookahead == '"') ADVANCE(59);
      if (lookahead == '\'') ADVANCE(65);
      if (lookahead == '(') ADVANCE(52);
      if (lookahead == ')') ADVANCE(53);
      if (lookahead == ',') ADVANCE(41);
      if (lookahead == '.') ADVANCE(46);
      if (lookahead == '/') ADVANCE(3);
      if (lookahead == ':') ADVANCE(48);
      if (lookahead == '=') ADVANCE(47);
      if (lookahead == '@') ADVANCE(51);
      if (lookahead == '[') ADVANCE(49);
      if (lookahead == '\\') ADVANCE(62);
      if (lookahead == ']') ADVANCE(50);
      if (lookahead == '{') ADVANCE(42);
      if (lookahead == '}') ADVANCE(43);
      if (lookahead == 'n' ||
          lookahead == 'r' ||
          lookahead == 't') ADVANCE(45);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(0)
      if (('0' <= lookahead && lookahead <= '9') ||
          lookahead == '_') ADVANCE(45);
      if (('a' <= lookahead && lookahead <= 'z')) ADVANCE(45);
      if (('A' <= lookahead && lookahead <= 'Z')) ADVANCE(44);
      END_STATE();
    case 1:
      if (lookahead == '"') ADVANCE(59);
      if (lookahead == '\\') ADVANCE(62);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(60);
      if (lookahead != 0) ADVANCE(61);
      END_STATE();
    case 2:
      if (lookahead == '(') ADVANCE(52);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(2)
      if (('0' <= lookahead && lookahead <= '9') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(55);
      END_STATE();
    case 3:
      if (lookahead == '/') ADVANCE(81);
      END_STATE();
    case 4:
      if (lookahead == '0') ADVANCE(76);
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(77);
      END_STATE();
    case 5:
      if (lookahead == '\\') ADVANCE(56);
      END_STATE();
    case 6:
      if (lookahead == 'a') ADVANCE(9);
      END_STATE();
    case 7:
      if (lookahead == 'e') ADVANCE(78);
      END_STATE();
    case 8:
      if (lookahead == 'e') ADVANCE(79);
      END_STATE();
    case 9:
      if (lookahead == 'l') ADVANCE(13);
      END_STATE();
    case 10:
      if (lookahead == 'l') ADVANCE(80);
      END_STATE();
    case 11:
      if (lookahead == 'l') ADVANCE(10);
      END_STATE();
    case 12:
      if (lookahead == 'r') ADVANCE(14);
      END_STATE();
    case 13:
      if (lookahead == 's') ADVANCE(8);
      END_STATE();
    case 14:
      if (lookahead == 'u') ADVANCE(7);
      END_STATE();
    case 15:
      if (lookahead == 'u') ADVANCE(18);
      if (lookahead == 'x') ADVANCE(38);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(15)
      if (lookahead == '"' ||
          lookahead == '\'' ||
          lookahead == '\\' ||
          lookahead == 'n' ||
          lookahead == 'r' ||
          lookahead == 't') ADVANCE(65);
      END_STATE();
    case 16:
      if (lookahead == 'u') ADVANCE(11);
      END_STATE();
    case 17:
      if (lookahead == '{') ADVANCE(42);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(17)
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(45);
      END_STATE();
    case 18:
      if (lookahead == '{') ADVANCE(36);
      END_STATE();
    case 19:
      if (lookahead == '}') ADVANCE(64);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'F') ||
          ('a' <= lookahead && lookahead <= 'f')) ADVANCE(19);
      END_STATE();
    case 20:
      if (lookahead == '+' ||
          lookahead == '-') ADVANCE(30);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(72);
      END_STATE();
    case 21:
      if (lookahead == '+' ||
          lookahead == '-') ADVANCE(31);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(70);
      END_STATE();
    case 22:
      if (lookahead == '+' ||
          lookahead == '-') ADVANCE(32);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(71);
      END_STATE();
    case 23:
      if (lookahead == '+' ||
          lookahead == '-') ADVANCE(33);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(68);
      END_STATE();
    case 24:
      if (lookahead == '0' ||
          lookahead == '1') ADVANCE(73);
      END_STATE();
    case 25:
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(25)
      if (('a' <= lookahead && lookahead <= 'z')) ADVANCE(54);
      END_STATE();
    case 26:
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(26)
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(66);
      END_STATE();
    case 27:
      if (('0' <= lookahead && lookahead <= '7')) ADVANCE(74);
      END_STATE();
    case 28:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(77);
      END_STATE();
    case 29:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(69);
      END_STATE();
    case 30:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(72);
      END_STATE();
    case 31:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(70);
      END_STATE();
    case 32:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(71);
      END_STATE();
    case 33:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(68);
      END_STATE();
    case 34:
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'F') ||
          ('a' <= lookahead && lookahead <= 'f')) ADVANCE(75);
      END_STATE();
    case 35:
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'F') ||
          ('a' <= lookahead && lookahead <= 'f')) ADVANCE(67);
      END_STATE();
    case 36:
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'F') ||
          ('a' <= lookahead && lookahead <= 'f')) ADVANCE(19);
      END_STATE();
    case 37:
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'f')) ADVANCE(63);
      END_STATE();
    case 38:
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'f')) ADVANCE(37);
      END_STATE();
    case 39:
      if (eof) ADVANCE(40);
      if (lookahead == '"') ADVANCE(59);
      if (lookahead == ')') ADVANCE(53);
      if (lookahead == ',') ADVANCE(41);
      if (lookahead == '-') ADVANCE(4);
      if (lookahead == '.') ADVANCE(46);
      if (lookahead == '/') ADVANCE(3);
      if (lookahead == '0') ADVANCE(76);
      if (lookahead == ':') ADVANCE(48);
      if (lookahead == '@') ADVANCE(51);
      if (lookahead == '[') ADVANCE(49);
      if (lookahead == '\\') ADVANCE(5);
      if (lookahead == ']') ADVANCE(50);
      if (lookahead == 'f') ADVANCE(6);
      if (lookahead == 'n') ADVANCE(16);
      if (lookahead == 't') ADVANCE(12);
      if (lookahead == '{') ADVANCE(42);
      if (lookahead == '}') ADVANCE(43);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(39)
      if (('1' <= lookahead && lookahead <= '9')) ADVANCE(77);
      if (('A' <= lookahead && lookahead <= 'Z')) ADVANCE(44);
      END_STATE();
    case 40:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 41:
      ACCEPT_TOKEN(anon_sym_COMMA);
      END_STATE();
    case 42:
      ACCEPT_TOKEN(anon_sym_LBRACE);
      END_STATE();
    case 43:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 44:
      ACCEPT_TOKEN(aux_sym_struct_name_token1);
      END_STATE();
    case 45:
      ACCEPT_TOKEN(aux_sym_struct_name_token2);
      END_STATE();
    case 46:
      ACCEPT_TOKEN(anon_sym_DOT);
      END_STATE();
    case 47:
      ACCEPT_TOKEN(anon_sym_EQ);
      END_STATE();
    case 48:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 49:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 50:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 51:
      ACCEPT_TOKEN(anon_sym_AT);
      END_STATE();
    case 52:
      ACCEPT_TOKEN(anon_sym_LPAREN);
      END_STATE();
    case 53:
      ACCEPT_TOKEN(anon_sym_RPAREN);
      END_STATE();
    case 54:
      ACCEPT_TOKEN(aux_sym_tag_token1);
      END_STATE();
    case 55:
      ACCEPT_TOKEN(aux_sym_tag_token2);
      END_STATE();
    case 56:
      ACCEPT_TOKEN(anon_sym_BSLASH_BSLASH);
      END_STATE();
    case 57:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead == '\t' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(57);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(58);
      END_STATE();
    case 58:
      ACCEPT_TOKEN(aux_sym_line_string_token1);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(58);
      END_STATE();
    case 59:
      ACCEPT_TOKEN(anon_sym_DQUOTE);
      END_STATE();
    case 60:
      ACCEPT_TOKEN(aux_sym_quoted_string_token1);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') ADVANCE(60);
      if (lookahead != 0 &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(61);
      END_STATE();
    case 61:
      ACCEPT_TOKEN(aux_sym_quoted_string_token1);
      if (lookahead != 0 &&
          lookahead != '"' &&
          lookahead != '\\') ADVANCE(61);
      END_STATE();
    case 62:
      ACCEPT_TOKEN(anon_sym_BSLASH);
      END_STATE();
    case 63:
      ACCEPT_TOKEN(aux_sym_escape_sequence_token1);
      END_STATE();
    case 64:
      ACCEPT_TOKEN(aux_sym_escape_sequence_token2);
      END_STATE();
    case 65:
      ACCEPT_TOKEN(aux_sym_escape_sequence_token3);
      END_STATE();
    case 66:
      ACCEPT_TOKEN(sym_identifier);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(66);
      END_STATE();
    case 67:
      ACCEPT_TOKEN(aux_sym_float_token1);
      if (lookahead == '_') ADVANCE(35);
      if (lookahead == 'P' ||
          lookahead == 'p') ADVANCE(23);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'F') ||
          ('a' <= lookahead && lookahead <= 'f')) ADVANCE(67);
      END_STATE();
    case 68:
      ACCEPT_TOKEN(aux_sym_float_token1);
      if (lookahead == '_') ADVANCE(33);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(68);
      END_STATE();
    case 69:
      ACCEPT_TOKEN(aux_sym_float_token2);
      if (lookahead == '_') ADVANCE(29);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(21);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(69);
      END_STATE();
    case 70:
      ACCEPT_TOKEN(aux_sym_float_token2);
      if (lookahead == '_') ADVANCE(31);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(70);
      END_STATE();
    case 71:
      ACCEPT_TOKEN(aux_sym_float_token3);
      if (lookahead == '_') ADVANCE(32);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(71);
      END_STATE();
    case 72:
      ACCEPT_TOKEN(aux_sym_float_token4);
      if (lookahead == '_') ADVANCE(30);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(72);
      END_STATE();
    case 73:
      ACCEPT_TOKEN(aux_sym_integer_token1);
      if (lookahead == '_') ADVANCE(24);
      if (lookahead == '0' ||
          lookahead == '1') ADVANCE(73);
      END_STATE();
    case 74:
      ACCEPT_TOKEN(aux_sym_integer_token2);
      if (lookahead == '_') ADVANCE(27);
      if (('0' <= lookahead && lookahead <= '7')) ADVANCE(74);
      END_STATE();
    case 75:
      ACCEPT_TOKEN(aux_sym_integer_token3);
      if (lookahead == '.') ADVANCE(35);
      if (lookahead == '_') ADVANCE(34);
      if (lookahead == 'P' ||
          lookahead == 'p') ADVANCE(22);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'F') ||
          ('a' <= lookahead && lookahead <= 'f')) ADVANCE(75);
      END_STATE();
    case 76:
      ACCEPT_TOKEN(aux_sym_integer_token4);
      if (lookahead == '.') ADVANCE(29);
      if (lookahead == '_') ADVANCE(28);
      if (lookahead == 'b') ADVANCE(24);
      if (lookahead == 'o') ADVANCE(27);
      if (lookahead == 'x') ADVANCE(34);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(20);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(77);
      END_STATE();
    case 77:
      ACCEPT_TOKEN(aux_sym_integer_token4);
      if (lookahead == '.') ADVANCE(29);
      if (lookahead == '_') ADVANCE(28);
      if (lookahead == 'E' ||
          lookahead == 'e') ADVANCE(20);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(77);
      END_STATE();
    case 78:
      ACCEPT_TOKEN(sym_true);
      END_STATE();
    case 79:
      ACCEPT_TOKEN(sym_false);
      END_STATE();
    case 80:
      ACCEPT_TOKEN(sym_null);
      END_STATE();
    case 81:
      ACCEPT_TOKEN(aux_sym_comment_token1);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(81);
      END_STATE();
    default:
      return false;
  }
}

static const TSLexMode ts_lex_modes[STATE_COUNT] = {
  [0] = {.lex_state = 0},
  [1] = {.lex_state = 39},
  [2] = {.lex_state = 39},
  [3] = {.lex_state = 39},
  [4] = {.lex_state = 39},
  [5] = {.lex_state = 39},
  [6] = {.lex_state = 39},
  [7] = {.lex_state = 39},
  [8] = {.lex_state = 39},
  [9] = {.lex_state = 39},
  [10] = {.lex_state = 39},
  [11] = {.lex_state = 39},
  [12] = {.lex_state = 39},
  [13] = {.lex_state = 39},
  [14] = {.lex_state = 39},
  [15] = {.lex_state = 39},
  [16] = {.lex_state = 39},
  [17] = {.lex_state = 39},
  [18] = {.lex_state = 39},
  [19] = {.lex_state = 39},
  [20] = {.lex_state = 39},
  [21] = {.lex_state = 39},
  [22] = {.lex_state = 39},
  [23] = {.lex_state = 39},
  [24] = {.lex_state = 39},
  [25] = {.lex_state = 0},
  [26] = {.lex_state = 39},
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
  [37] = {.lex_state = 39},
  [38] = {.lex_state = 39},
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
  [49] = {.lex_state = 1},
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
  [62] = {.lex_state = 1},
  [63] = {.lex_state = 0},
  [64] = {.lex_state = 0},
  [65] = {.lex_state = 0},
  [66] = {.lex_state = 0},
  [67] = {.lex_state = 0},
  [68] = {.lex_state = 0},
  [69] = {.lex_state = 0},
  [70] = {.lex_state = 0},
  [71] = {.lex_state = 0},
  [72] = {.lex_state = 0},
  [73] = {.lex_state = 0},
  [74] = {.lex_state = 0},
  [75] = {.lex_state = 1},
  [76] = {.lex_state = 0},
  [77] = {.lex_state = 0},
  [78] = {.lex_state = 0},
  [79] = {.lex_state = 0},
  [80] = {.lex_state = 0},
  [81] = {.lex_state = 2},
  [82] = {.lex_state = 17},
  [83] = {.lex_state = 0},
  [84] = {.lex_state = 2},
  [85] = {.lex_state = 0},
  [86] = {.lex_state = 15},
  [87] = {.lex_state = 0},
  [88] = {.lex_state = 17},
  [89] = {.lex_state = 0},
  [90] = {.lex_state = 0},
  [91] = {.lex_state = 0},
  [92] = {.lex_state = 1},
  [93] = {.lex_state = 17},
  [94] = {.lex_state = 2},
  [95] = {.lex_state = 0},
  [96] = {.lex_state = 0},
  [97] = {.lex_state = 25},
  [98] = {.lex_state = 0},
  [99] = {.lex_state = 0},
  [100] = {.lex_state = 0},
  [101] = {.lex_state = 0},
  [102] = {.lex_state = 0},
  [103] = {.lex_state = 0},
  [104] = {.lex_state = 0},
  [105] = {.lex_state = 0},
  [106] = {.lex_state = 26},
  [107] = {.lex_state = 0},
  [108] = {.lex_state = 0},
  [109] = {.lex_state = 0},
  [110] = {.lex_state = 0},
  [111] = {.lex_state = 0},
  [112] = {.lex_state = 0},
  [113] = {.lex_state = 0},
  [114] = {.lex_state = 0},
  [115] = {.lex_state = 0},
  [116] = {.lex_state = 0},
  [117] = {.lex_state = 0},
  [118] = {.lex_state = 0},
  [119] = {.lex_state = 0},
  [120] = {.lex_state = 0},
  [121] = {.lex_state = 0},
  [122] = {.lex_state = 57},
  [123] = {.lex_state = 0},
  [124] = {.lex_state = 0},
  [125] = {.lex_state = 26},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
    [anon_sym_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
    [aux_sym_struct_name_token1] = ACTIONS(1),
    [aux_sym_struct_name_token2] = ACTIONS(1),
    [anon_sym_DOT] = ACTIONS(1),
    [anon_sym_EQ] = ACTIONS(1),
    [anon_sym_COLON] = ACTIONS(1),
    [anon_sym_LBRACK] = ACTIONS(1),
    [anon_sym_RBRACK] = ACTIONS(1),
    [anon_sym_AT] = ACTIONS(1),
    [anon_sym_LPAREN] = ACTIONS(1),
    [anon_sym_RPAREN] = ACTIONS(1),
    [aux_sym_tag_token1] = ACTIONS(1),
    [aux_sym_tag_token2] = ACTIONS(1),
    [anon_sym_DQUOTE] = ACTIONS(1),
    [anon_sym_BSLASH] = ACTIONS(1),
    [aux_sym_escape_sequence_token3] = ACTIONS(1),
    [aux_sym_comment_token1] = ACTIONS(1),
  },
  [1] = {
    [sym_document] = STATE(121),
    [sym__value] = STATE(120),
    [sym_top_level_struct] = STATE(120),
    [sym_struct] = STATE(120),
    [sym_struct_name] = STATE(119),
    [sym_struct_field] = STATE(47),
    [sym_map] = STATE(120),
    [sym_array] = STATE(120),
    [sym_tag_string] = STATE(120),
    [sym_string] = STATE(120),
    [sym_line_string] = STATE(19),
    [sym_quoted_string] = STATE(27),
    [sym_float] = STATE(120),
    [sym_integer] = STATE(120),
    [sym_comment] = STATE(118),
    [aux_sym_string_repeat1] = STATE(19),
    [aux_sym_comment_repeat1] = STATE(14),
    [ts_builtin_sym_end] = ACTIONS(3),
    [anon_sym_LBRACE] = ACTIONS(5),
    [aux_sym_struct_name_token1] = ACTIONS(7),
    [anon_sym_DOT] = ACTIONS(9),
    [anon_sym_LBRACK] = ACTIONS(11),
    [anon_sym_AT] = ACTIONS(13),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(15),
    [anon_sym_DQUOTE] = ACTIONS(17),
    [aux_sym_float_token1] = ACTIONS(19),
    [aux_sym_float_token2] = ACTIONS(19),
    [aux_sym_float_token3] = ACTIONS(19),
    [aux_sym_float_token4] = ACTIONS(19),
    [aux_sym_integer_token1] = ACTIONS(21),
    [aux_sym_integer_token2] = ACTIONS(21),
    [aux_sym_integer_token3] = ACTIONS(23),
    [aux_sym_integer_token4] = ACTIONS(23),
    [sym_true] = ACTIONS(25),
    [sym_false] = ACTIONS(25),
    [sym_null] = ACTIONS(25),
    [aux_sym_comment_token1] = ACTIONS(27),
  },
  [2] = {
    [sym__value] = STATE(83),
    [sym_struct] = STATE(83),
    [sym_struct_name] = STATE(119),
    [sym_map] = STATE(83),
    [sym_array] = STATE(83),
    [sym_array_elem] = STATE(36),
    [sym_tag_string] = STATE(83),
    [sym_string] = STATE(83),
    [sym_line_string] = STATE(19),
    [sym_quoted_string] = STATE(27),
    [sym_float] = STATE(83),
    [sym_integer] = STATE(83),
    [sym_comment] = STATE(7),
    [aux_sym_string_repeat1] = STATE(19),
    [aux_sym_comment_repeat1] = STATE(14),
    [anon_sym_LBRACE] = ACTIONS(5),
    [aux_sym_struct_name_token1] = ACTIONS(7),
    [anon_sym_LBRACK] = ACTIONS(11),
    [anon_sym_RBRACK] = ACTIONS(29),
    [anon_sym_AT] = ACTIONS(13),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(15),
    [anon_sym_DQUOTE] = ACTIONS(17),
    [aux_sym_float_token1] = ACTIONS(19),
    [aux_sym_float_token2] = ACTIONS(19),
    [aux_sym_float_token3] = ACTIONS(19),
    [aux_sym_float_token4] = ACTIONS(19),
    [aux_sym_integer_token1] = ACTIONS(21),
    [aux_sym_integer_token2] = ACTIONS(21),
    [aux_sym_integer_token3] = ACTIONS(23),
    [aux_sym_integer_token4] = ACTIONS(23),
    [sym_true] = ACTIONS(31),
    [sym_false] = ACTIONS(31),
    [sym_null] = ACTIONS(31),
    [aux_sym_comment_token1] = ACTIONS(27),
  },
  [3] = {
    [sym__value] = STATE(83),
    [sym_struct] = STATE(83),
    [sym_struct_name] = STATE(119),
    [sym_map] = STATE(83),
    [sym_array] = STATE(83),
    [sym_array_elem] = STATE(89),
    [sym_tag_string] = STATE(83),
    [sym_string] = STATE(83),
    [sym_line_string] = STATE(19),
    [sym_quoted_string] = STATE(27),
    [sym_float] = STATE(83),
    [sym_integer] = STATE(83),
    [sym_comment] = STATE(8),
    [aux_sym_string_repeat1] = STATE(19),
    [aux_sym_comment_repeat1] = STATE(14),
    [anon_sym_LBRACE] = ACTIONS(5),
    [aux_sym_struct_name_token1] = ACTIONS(7),
    [anon_sym_LBRACK] = ACTIONS(11),
    [anon_sym_RBRACK] = ACTIONS(33),
    [anon_sym_AT] = ACTIONS(13),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(15),
    [anon_sym_DQUOTE] = ACTIONS(17),
    [aux_sym_float_token1] = ACTIONS(19),
    [aux_sym_float_token2] = ACTIONS(19),
    [aux_sym_float_token3] = ACTIONS(19),
    [aux_sym_float_token4] = ACTIONS(19),
    [aux_sym_integer_token1] = ACTIONS(21),
    [aux_sym_integer_token2] = ACTIONS(21),
    [aux_sym_integer_token3] = ACTIONS(23),
    [aux_sym_integer_token4] = ACTIONS(23),
    [sym_true] = ACTIONS(31),
    [sym_false] = ACTIONS(31),
    [sym_null] = ACTIONS(31),
    [aux_sym_comment_token1] = ACTIONS(27),
  },
  [4] = {
    [sym__value] = STATE(83),
    [sym_struct] = STATE(83),
    [sym_struct_name] = STATE(119),
    [sym_map] = STATE(83),
    [sym_array] = STATE(83),
    [sym_array_elem] = STATE(89),
    [sym_tag_string] = STATE(83),
    [sym_string] = STATE(83),
    [sym_line_string] = STATE(19),
    [sym_quoted_string] = STATE(27),
    [sym_float] = STATE(83),
    [sym_integer] = STATE(83),
    [sym_comment] = STATE(6),
    [aux_sym_string_repeat1] = STATE(19),
    [aux_sym_comment_repeat1] = STATE(14),
    [anon_sym_LBRACE] = ACTIONS(5),
    [aux_sym_struct_name_token1] = ACTIONS(7),
    [anon_sym_LBRACK] = ACTIONS(11),
    [anon_sym_RBRACK] = ACTIONS(35),
    [anon_sym_AT] = ACTIONS(13),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(15),
    [anon_sym_DQUOTE] = ACTIONS(17),
    [aux_sym_float_token1] = ACTIONS(19),
    [aux_sym_float_token2] = ACTIONS(19),
    [aux_sym_float_token3] = ACTIONS(19),
    [aux_sym_float_token4] = ACTIONS(19),
    [aux_sym_integer_token1] = ACTIONS(21),
    [aux_sym_integer_token2] = ACTIONS(21),
    [aux_sym_integer_token3] = ACTIONS(23),
    [aux_sym_integer_token4] = ACTIONS(23),
    [sym_true] = ACTIONS(31),
    [sym_false] = ACTIONS(31),
    [sym_null] = ACTIONS(31),
    [aux_sym_comment_token1] = ACTIONS(27),
  },
  [5] = {
    [sym__value] = STATE(83),
    [sym_struct] = STATE(83),
    [sym_struct_name] = STATE(119),
    [sym_map] = STATE(83),
    [sym_array] = STATE(83),
    [sym_array_elem] = STATE(89),
    [sym_tag_string] = STATE(83),
    [sym_string] = STATE(83),
    [sym_line_string] = STATE(19),
    [sym_quoted_string] = STATE(27),
    [sym_float] = STATE(83),
    [sym_integer] = STATE(83),
    [sym_comment] = STATE(10),
    [aux_sym_string_repeat1] = STATE(19),
    [aux_sym_comment_repeat1] = STATE(14),
    [anon_sym_LBRACE] = ACTIONS(5),
    [aux_sym_struct_name_token1] = ACTIONS(7),
    [anon_sym_LBRACK] = ACTIONS(11),
    [anon_sym_AT] = ACTIONS(13),
    [anon_sym_BSLASH_BSLASH] = ACTIONS(15),
    [anon_sym_DQUOTE] = ACTIONS(17),
    [aux_sym_float_token1] = ACTIONS(19),
    [aux_sym_float_token2] = ACTIONS(19),
    [aux_sym_float_token3] = ACTIONS(19),
    [aux_sym_float_token4] = ACTIONS(19),
    [aux_sym_integer_token1] = ACTIONS(21),
    [aux_sym_integer_token2] = ACTIONS(21),
    [aux_sym_integer_token3] = ACTIONS(23),
    [aux_sym_integer_token4] = ACTIONS(23),
    [sym_true] = ACTIONS(31),
    [sym_false] = ACTIONS(31),
    [sym_null] = ACTIONS(31),
    [aux_sym_comment_token1] = ACTIONS(27),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 15,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      aux_sym_struct_name_token1,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(33), 1,
      anon_sym_RBRACK,
    STATE(27), 1,
      sym_quoted_string,
    STATE(119), 1,
      sym_struct_name,
    ACTIONS(21), 2,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
    ACTIONS(23), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(37), 3,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(19), 4,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
    STATE(91), 8,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
      sym_float,
      sym_integer,
  [61] = 15,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      aux_sym_struct_name_token1,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(39), 1,
      anon_sym_RBRACK,
    STATE(27), 1,
      sym_quoted_string,
    STATE(119), 1,
      sym_struct_name,
    ACTIONS(21), 2,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
    ACTIONS(23), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(37), 3,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(19), 4,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
    STATE(91), 8,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
      sym_float,
      sym_integer,
  [122] = 15,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      aux_sym_struct_name_token1,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(41), 1,
      anon_sym_RBRACK,
    STATE(27), 1,
      sym_quoted_string,
    STATE(119), 1,
      sym_struct_name,
    ACTIONS(21), 2,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
    ACTIONS(23), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(37), 3,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(19), 4,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
    STATE(91), 8,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
      sym_float,
      sym_integer,
  [183] = 14,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      aux_sym_struct_name_token1,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    STATE(27), 1,
      sym_quoted_string,
    STATE(119), 1,
      sym_struct_name,
    ACTIONS(21), 2,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
    ACTIONS(23), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(43), 3,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(19), 4,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
    STATE(87), 8,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
      sym_float,
      sym_integer,
  [241] = 14,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      aux_sym_struct_name_token1,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    STATE(27), 1,
      sym_quoted_string,
    STATE(119), 1,
      sym_struct_name,
    ACTIONS(21), 2,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
    ACTIONS(23), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(37), 3,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(19), 4,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
    STATE(91), 8,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
      sym_float,
      sym_integer,
  [299] = 14,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      aux_sym_struct_name_token1,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    STATE(27), 1,
      sym_quoted_string,
    STATE(119), 1,
      sym_struct_name,
    ACTIONS(21), 2,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
    ACTIONS(23), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(45), 3,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(19), 4,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
    STATE(78), 8,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
      sym_float,
      sym_integer,
  [357] = 14,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      aux_sym_struct_name_token1,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    STATE(27), 1,
      sym_quoted_string,
    STATE(119), 1,
      sym_struct_name,
    ACTIONS(21), 2,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
    ACTIONS(23), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(47), 3,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(19), 4,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
    STATE(85), 8,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
      sym_float,
      sym_integer,
  [415] = 14,
    ACTIONS(5), 1,
      anon_sym_LBRACE,
    ACTIONS(7), 1,
      aux_sym_struct_name_token1,
    ACTIONS(11), 1,
      anon_sym_LBRACK,
    ACTIONS(13), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    STATE(27), 1,
      sym_quoted_string,
    STATE(119), 1,
      sym_struct_name,
    ACTIONS(21), 2,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
    ACTIONS(23), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(49), 3,
      sym_true,
      sym_false,
      sym_null,
    ACTIONS(19), 4,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
    STATE(80), 8,
      sym__value,
      sym_struct,
      sym_map,
      sym_array,
      sym_tag_string,
      sym_string,
      sym_float,
      sym_integer,
  [473] = 4,
    ACTIONS(55), 1,
      aux_sym_comment_token1,
    STATE(15), 1,
      aux_sym_comment_repeat1,
    ACTIONS(53), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    ACTIONS(51), 19,
      ts_builtin_sym_end,
      anon_sym_LBRACE,
      anon_sym_RBRACE,
      aux_sym_struct_name_token1,
      anon_sym_DOT,
      anon_sym_LBRACK,
      anon_sym_RBRACK,
      anon_sym_AT,
      anon_sym_BSLASH_BSLASH,
      anon_sym_DQUOTE,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
      sym_true,
      sym_false,
      sym_null,
  [505] = 4,
    ACTIONS(61), 1,
      aux_sym_comment_token1,
    STATE(15), 1,
      aux_sym_comment_repeat1,
    ACTIONS(59), 2,
      aux_sym_integer_token3,
      aux_sym_integer_token4,
    ACTIONS(57), 19,
      ts_builtin_sym_end,
      anon_sym_LBRACE,
      anon_sym_RBRACE,
      aux_sym_struct_name_token1,
      anon_sym_DOT,
      anon_sym_LBRACK,
      anon_sym_RBRACK,
      anon_sym_AT,
      anon_sym_BSLASH_BSLASH,
      anon_sym_DQUOTE,
      aux_sym_float_token1,
      aux_sym_float_token2,
      aux_sym_float_token3,
      aux_sym_float_token4,
      aux_sym_integer_token1,
      aux_sym_integer_token2,
      sym_true,
      sym_false,
      sym_null,
  [537] = 12,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(64), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(23), 1,
      sym_comment,
    STATE(27), 1,
      sym_quoted_string,
    STATE(31), 1,
      sym_map_field,
    STATE(45), 1,
      sym_struct_field,
    STATE(117), 1,
      sym_string,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
  [575] = 10,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(66), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(26), 1,
      sym_comment,
    STATE(27), 1,
      sym_quoted_string,
    STATE(90), 1,
      sym_map_field,
    STATE(117), 1,
      sym_string,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
  [607] = 10,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(68), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(24), 1,
      sym_comment,
    STATE(27), 1,
      sym_quoted_string,
    STATE(90), 1,
      sym_map_field,
    STATE(117), 1,
      sym_string,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
  [639] = 3,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    STATE(20), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(70), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
      aux_sym_comment_token1,
  [656] = 3,
    ACTIONS(74), 1,
      anon_sym_BSLASH_BSLASH,
    STATE(20), 2,
      sym_line_string,
      aux_sym_string_repeat1,
    ACTIONS(72), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
      aux_sym_comment_token1,
  [673] = 9,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(27), 1,
      sym_quoted_string,
    STATE(38), 1,
      sym_comment,
    STATE(90), 1,
      sym_map_field,
    STATE(117), 1,
      sym_string,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
  [702] = 1,
    ACTIONS(77), 8,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
      anon_sym_BSLASH_BSLASH,
      aux_sym_comment_token1,
  [713] = 7,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(79), 1,
      anon_sym_RBRACE,
    ACTIONS(81), 1,
      anon_sym_DOT,
    STATE(27), 1,
      sym_quoted_string,
    STATE(104), 1,
      sym_string,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
  [736] = 6,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(66), 1,
      anon_sym_RBRACE,
    STATE(27), 1,
      sym_quoted_string,
    STATE(104), 1,
      sym_string,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
  [756] = 1,
    ACTIONS(83), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
      aux_sym_comment_token1,
  [766] = 6,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    ACTIONS(85), 1,
      anon_sym_RBRACE,
    STATE(27), 1,
      sym_quoted_string,
    STATE(104), 1,
      sym_string,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
  [786] = 1,
    ACTIONS(70), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
      aux_sym_comment_token1,
  [796] = 1,
    ACTIONS(87), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_COLON,
      anon_sym_RBRACK,
      anon_sym_RPAREN,
      aux_sym_comment_token1,
  [806] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(89), 1,
      ts_builtin_sym_end,
    ACTIONS(91), 1,
      anon_sym_COMMA,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(70), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(103), 1,
      sym_comment,
  [825] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(68), 1,
      anon_sym_RBRACE,
    ACTIONS(93), 1,
      anon_sym_COMMA,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(76), 1,
      aux_sym_map_repeat1,
    STATE(112), 1,
      sym_comment,
  [844] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(95), 1,
      anon_sym_COMMA,
    ACTIONS(97), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(30), 1,
      aux_sym_map_repeat1,
    STATE(114), 1,
      sym_comment,
  [863] = 6,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(99), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(77), 1,
      sym_struct_field,
    STATE(96), 1,
      sym_comment,
  [882] = 6,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(101), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(77), 1,
      sym_struct_field,
    STATE(95), 1,
      sym_comment,
  [901] = 6,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(103), 1,
      ts_builtin_sym_end,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(77), 1,
      sym_struct_field,
    STATE(100), 1,
      sym_comment,
  [920] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(105), 1,
      anon_sym_COMMA,
    ACTIONS(107), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(44), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(123), 1,
      sym_comment,
  [939] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(39), 1,
      anon_sym_RBRACK,
    ACTIONS(109), 1,
      anon_sym_COMMA,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(42), 1,
      aux_sym_array_repeat1,
    STATE(115), 1,
      sym_comment,
  [958] = 5,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    STATE(27), 1,
      sym_quoted_string,
    STATE(109), 1,
      sym_string,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
  [975] = 5,
    ACTIONS(15), 1,
      anon_sym_BSLASH_BSLASH,
    ACTIONS(17), 1,
      anon_sym_DQUOTE,
    STATE(27), 1,
      sym_quoted_string,
    STATE(104), 1,
      sym_string,
    STATE(19), 2,
      sym_line_string,
      aux_sym_string_repeat1,
  [992] = 6,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(111), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(35), 1,
      sym_struct_field,
    STATE(98), 1,
      sym_comment,
  [1011] = 6,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(89), 1,
      ts_builtin_sym_end,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(77), 1,
      sym_struct_field,
    STATE(101), 1,
      sym_comment,
  [1030] = 6,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(113), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(77), 1,
      sym_struct_field,
    STATE(99), 1,
      sym_comment,
  [1049] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(35), 1,
      anon_sym_RBRACK,
    ACTIONS(115), 1,
      anon_sym_COMMA,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(79), 1,
      aux_sym_array_repeat1,
    STATE(111), 1,
      sym_comment,
  [1068] = 6,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(117), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(77), 1,
      sym_struct_field,
    STATE(102), 1,
      sym_comment,
  [1087] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(113), 1,
      anon_sym_RBRACE,
    ACTIONS(119), 1,
      anon_sym_COMMA,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(70), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(116), 1,
      sym_comment,
  [1106] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(121), 1,
      anon_sym_COMMA,
    ACTIONS(123), 1,
      anon_sym_RBRACE,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(46), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(105), 1,
      sym_comment,
  [1125] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(117), 1,
      anon_sym_RBRACE,
    ACTIONS(125), 1,
      anon_sym_COMMA,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(70), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(108), 1,
      sym_comment,
  [1144] = 6,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    ACTIONS(127), 1,
      ts_builtin_sym_end,
    ACTIONS(129), 1,
      anon_sym_COMMA,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(29), 1,
      aux_sym_top_level_struct_repeat1,
    STATE(107), 1,
      sym_comment,
  [1163] = 5,
    ACTIONS(9), 1,
      anon_sym_DOT,
    ACTIONS(27), 1,
      aux_sym_comment_token1,
    STATE(14), 1,
      aux_sym_comment_repeat1,
    STATE(77), 1,
      sym_struct_field,
    STATE(118), 1,
      sym_comment,
  [1179] = 4,
    ACTIONS(131), 1,
      anon_sym_DQUOTE,
    ACTIONS(133), 1,
      aux_sym_quoted_string_token1,
    ACTIONS(136), 1,
      anon_sym_BSLASH,
    STATE(49), 2,
      sym_escape_sequence,
      aux_sym_quoted_string_repeat1,
  [1193] = 1,
    ACTIONS(139), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1201] = 1,
    ACTIONS(141), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1209] = 1,
    ACTIONS(143), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1217] = 1,
    ACTIONS(145), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1225] = 1,
    ACTIONS(147), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1233] = 1,
    ACTIONS(149), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1241] = 1,
    ACTIONS(151), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1249] = 1,
    ACTIONS(153), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1257] = 1,
    ACTIONS(155), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1265] = 1,
    ACTIONS(143), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1273] = 1,
    ACTIONS(157), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1281] = 1,
    ACTIONS(159), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1289] = 4,
    ACTIONS(161), 1,
      anon_sym_DQUOTE,
    ACTIONS(163), 1,
      aux_sym_quoted_string_token1,
    ACTIONS(165), 1,
      anon_sym_BSLASH,
    STATE(49), 2,
      sym_escape_sequence,
      aux_sym_quoted_string_repeat1,
  [1303] = 1,
    ACTIONS(167), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1311] = 1,
    ACTIONS(169), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1319] = 1,
    ACTIONS(171), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1327] = 1,
    ACTIONS(173), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1335] = 1,
    ACTIONS(175), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1343] = 1,
    ACTIONS(177), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1351] = 1,
    ACTIONS(179), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1359] = 3,
    ACTIONS(183), 1,
      anon_sym_COMMA,
    STATE(70), 1,
      aux_sym_top_level_struct_repeat1,
    ACTIONS(181), 3,
      ts_builtin_sym_end,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1371] = 1,
    ACTIONS(186), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1379] = 1,
    ACTIONS(188), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1387] = 1,
    ACTIONS(190), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1395] = 1,
    ACTIONS(192), 5,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1403] = 4,
    ACTIONS(165), 1,
      anon_sym_BSLASH,
    ACTIONS(194), 1,
      anon_sym_DQUOTE,
    ACTIONS(196), 1,
      aux_sym_quoted_string_token1,
    STATE(62), 2,
      sym_escape_sequence,
      aux_sym_quoted_string_repeat1,
  [1417] = 3,
    ACTIONS(198), 1,
      anon_sym_COMMA,
    STATE(76), 1,
      aux_sym_map_repeat1,
    ACTIONS(201), 2,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1428] = 1,
    ACTIONS(181), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1435] = 1,
    ACTIONS(203), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1442] = 3,
    ACTIONS(205), 1,
      anon_sym_COMMA,
    STATE(79), 1,
      aux_sym_array_repeat1,
    ACTIONS(208), 2,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1453] = 1,
    ACTIONS(210), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1460] = 3,
    ACTIONS(212), 1,
      anon_sym_LPAREN,
    ACTIONS(214), 1,
      aux_sym_tag_token2,
    STATE(94), 1,
      aux_sym_tag_repeat1,
  [1470] = 3,
    ACTIONS(216), 1,
      anon_sym_LBRACE,
    ACTIONS(218), 1,
      aux_sym_struct_name_token2,
    STATE(88), 1,
      aux_sym_struct_name_repeat1,
  [1480] = 1,
    ACTIONS(220), 3,
      anon_sym_COMMA,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1486] = 3,
    ACTIONS(222), 1,
      anon_sym_LPAREN,
    ACTIONS(224), 1,
      aux_sym_tag_token2,
    STATE(81), 1,
      aux_sym_tag_repeat1,
  [1496] = 1,
    ACTIONS(226), 3,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1502] = 1,
    ACTIONS(228), 3,
      aux_sym_escape_sequence_token1,
      aux_sym_escape_sequence_token2,
      aux_sym_escape_sequence_token3,
  [1508] = 1,
    ACTIONS(230), 3,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1514] = 3,
    ACTIONS(232), 1,
      anon_sym_LBRACE,
    ACTIONS(234), 1,
      aux_sym_struct_name_token2,
    STATE(88), 1,
      aux_sym_struct_name_repeat1,
  [1524] = 1,
    ACTIONS(208), 3,
      anon_sym_COMMA,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1530] = 1,
    ACTIONS(201), 3,
      anon_sym_COMMA,
      anon_sym_RBRACE,
      aux_sym_comment_token1,
  [1536] = 1,
    ACTIONS(237), 3,
      anon_sym_COMMA,
      anon_sym_RBRACK,
      aux_sym_comment_token1,
  [1542] = 2,
    ACTIONS(241), 1,
      aux_sym_quoted_string_token1,
    ACTIONS(239), 2,
      anon_sym_DQUOTE,
      anon_sym_BSLASH,
  [1550] = 3,
    ACTIONS(243), 1,
      anon_sym_LBRACE,
    ACTIONS(245), 1,
      aux_sym_struct_name_token2,
    STATE(82), 1,
      aux_sym_struct_name_repeat1,
  [1560] = 3,
    ACTIONS(247), 1,
      anon_sym_LPAREN,
    ACTIONS(249), 1,
      aux_sym_tag_token2,
    STATE(94), 1,
      aux_sym_tag_repeat1,
  [1570] = 2,
    ACTIONS(81), 1,
      anon_sym_DOT,
    ACTIONS(252), 1,
      anon_sym_RBRACE,
  [1577] = 2,
    ACTIONS(81), 1,
      anon_sym_DOT,
    ACTIONS(254), 1,
      anon_sym_RBRACE,
  [1584] = 2,
    ACTIONS(256), 1,
      aux_sym_tag_token1,
    STATE(110), 1,
      sym_tag,
  [1591] = 2,
    ACTIONS(81), 1,
      anon_sym_DOT,
    ACTIONS(107), 1,
      anon_sym_RBRACE,
  [1598] = 2,
    ACTIONS(81), 1,
      anon_sym_DOT,
    ACTIONS(99), 1,
      anon_sym_RBRACE,
  [1605] = 2,
    ACTIONS(81), 1,
      anon_sym_DOT,
    ACTIONS(258), 1,
      ts_builtin_sym_end,
  [1612] = 2,
    ACTIONS(81), 1,
      anon_sym_DOT,
    ACTIONS(103), 1,
      ts_builtin_sym_end,
  [1619] = 2,
    ACTIONS(81), 1,
      anon_sym_DOT,
    ACTIONS(101), 1,
      anon_sym_RBRACE,
  [1626] = 1,
    ACTIONS(103), 1,
      ts_builtin_sym_end,
  [1630] = 1,
    ACTIONS(260), 1,
      anon_sym_COLON,
  [1634] = 1,
    ACTIONS(117), 1,
      anon_sym_RBRACE,
  [1638] = 1,
    ACTIONS(262), 1,
      sym_identifier,
  [1642] = 1,
    ACTIONS(89), 1,
      ts_builtin_sym_end,
  [1646] = 1,
    ACTIONS(101), 1,
      anon_sym_RBRACE,
  [1650] = 1,
    ACTIONS(264), 1,
      anon_sym_RPAREN,
  [1654] = 1,
    ACTIONS(266), 1,
      anon_sym_LPAREN,
  [1658] = 1,
    ACTIONS(33), 1,
      anon_sym_RBRACK,
  [1662] = 1,
    ACTIONS(66), 1,
      anon_sym_RBRACE,
  [1666] = 1,
    ACTIONS(268), 1,
      anon_sym_EQ,
  [1670] = 1,
    ACTIONS(68), 1,
      anon_sym_RBRACE,
  [1674] = 1,
    ACTIONS(35), 1,
      anon_sym_RBRACK,
  [1678] = 1,
    ACTIONS(99), 1,
      anon_sym_RBRACE,
  [1682] = 1,
    ACTIONS(270), 1,
      anon_sym_COLON,
  [1686] = 1,
    ACTIONS(81), 1,
      anon_sym_DOT,
  [1690] = 1,
    ACTIONS(272), 1,
      anon_sym_LBRACE,
  [1694] = 1,
    ACTIONS(274), 1,
      ts_builtin_sym_end,
  [1698] = 1,
    ACTIONS(276), 1,
      ts_builtin_sym_end,
  [1702] = 1,
    ACTIONS(278), 1,
      aux_sym_line_string_token1,
  [1706] = 1,
    ACTIONS(113), 1,
      anon_sym_RBRACE,
  [1710] = 1,
    ACTIONS(280), 1,
      anon_sym_EQ,
  [1714] = 1,
    ACTIONS(282), 1,
      sym_identifier,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(6)] = 0,
  [SMALL_STATE(7)] = 61,
  [SMALL_STATE(8)] = 122,
  [SMALL_STATE(9)] = 183,
  [SMALL_STATE(10)] = 241,
  [SMALL_STATE(11)] = 299,
  [SMALL_STATE(12)] = 357,
  [SMALL_STATE(13)] = 415,
  [SMALL_STATE(14)] = 473,
  [SMALL_STATE(15)] = 505,
  [SMALL_STATE(16)] = 537,
  [SMALL_STATE(17)] = 575,
  [SMALL_STATE(18)] = 607,
  [SMALL_STATE(19)] = 639,
  [SMALL_STATE(20)] = 656,
  [SMALL_STATE(21)] = 673,
  [SMALL_STATE(22)] = 702,
  [SMALL_STATE(23)] = 713,
  [SMALL_STATE(24)] = 736,
  [SMALL_STATE(25)] = 756,
  [SMALL_STATE(26)] = 766,
  [SMALL_STATE(27)] = 786,
  [SMALL_STATE(28)] = 796,
  [SMALL_STATE(29)] = 806,
  [SMALL_STATE(30)] = 825,
  [SMALL_STATE(31)] = 844,
  [SMALL_STATE(32)] = 863,
  [SMALL_STATE(33)] = 882,
  [SMALL_STATE(34)] = 901,
  [SMALL_STATE(35)] = 920,
  [SMALL_STATE(36)] = 939,
  [SMALL_STATE(37)] = 958,
  [SMALL_STATE(38)] = 975,
  [SMALL_STATE(39)] = 992,
  [SMALL_STATE(40)] = 1011,
  [SMALL_STATE(41)] = 1030,
  [SMALL_STATE(42)] = 1049,
  [SMALL_STATE(43)] = 1068,
  [SMALL_STATE(44)] = 1087,
  [SMALL_STATE(45)] = 1106,
  [SMALL_STATE(46)] = 1125,
  [SMALL_STATE(47)] = 1144,
  [SMALL_STATE(48)] = 1163,
  [SMALL_STATE(49)] = 1179,
  [SMALL_STATE(50)] = 1193,
  [SMALL_STATE(51)] = 1201,
  [SMALL_STATE(52)] = 1209,
  [SMALL_STATE(53)] = 1217,
  [SMALL_STATE(54)] = 1225,
  [SMALL_STATE(55)] = 1233,
  [SMALL_STATE(56)] = 1241,
  [SMALL_STATE(57)] = 1249,
  [SMALL_STATE(58)] = 1257,
  [SMALL_STATE(59)] = 1265,
  [SMALL_STATE(60)] = 1273,
  [SMALL_STATE(61)] = 1281,
  [SMALL_STATE(62)] = 1289,
  [SMALL_STATE(63)] = 1303,
  [SMALL_STATE(64)] = 1311,
  [SMALL_STATE(65)] = 1319,
  [SMALL_STATE(66)] = 1327,
  [SMALL_STATE(67)] = 1335,
  [SMALL_STATE(68)] = 1343,
  [SMALL_STATE(69)] = 1351,
  [SMALL_STATE(70)] = 1359,
  [SMALL_STATE(71)] = 1371,
  [SMALL_STATE(72)] = 1379,
  [SMALL_STATE(73)] = 1387,
  [SMALL_STATE(74)] = 1395,
  [SMALL_STATE(75)] = 1403,
  [SMALL_STATE(76)] = 1417,
  [SMALL_STATE(77)] = 1428,
  [SMALL_STATE(78)] = 1435,
  [SMALL_STATE(79)] = 1442,
  [SMALL_STATE(80)] = 1453,
  [SMALL_STATE(81)] = 1460,
  [SMALL_STATE(82)] = 1470,
  [SMALL_STATE(83)] = 1480,
  [SMALL_STATE(84)] = 1486,
  [SMALL_STATE(85)] = 1496,
  [SMALL_STATE(86)] = 1502,
  [SMALL_STATE(87)] = 1508,
  [SMALL_STATE(88)] = 1514,
  [SMALL_STATE(89)] = 1524,
  [SMALL_STATE(90)] = 1530,
  [SMALL_STATE(91)] = 1536,
  [SMALL_STATE(92)] = 1542,
  [SMALL_STATE(93)] = 1550,
  [SMALL_STATE(94)] = 1560,
  [SMALL_STATE(95)] = 1570,
  [SMALL_STATE(96)] = 1577,
  [SMALL_STATE(97)] = 1584,
  [SMALL_STATE(98)] = 1591,
  [SMALL_STATE(99)] = 1598,
  [SMALL_STATE(100)] = 1605,
  [SMALL_STATE(101)] = 1612,
  [SMALL_STATE(102)] = 1619,
  [SMALL_STATE(103)] = 1626,
  [SMALL_STATE(104)] = 1630,
  [SMALL_STATE(105)] = 1634,
  [SMALL_STATE(106)] = 1638,
  [SMALL_STATE(107)] = 1642,
  [SMALL_STATE(108)] = 1646,
  [SMALL_STATE(109)] = 1650,
  [SMALL_STATE(110)] = 1654,
  [SMALL_STATE(111)] = 1658,
  [SMALL_STATE(112)] = 1662,
  [SMALL_STATE(113)] = 1666,
  [SMALL_STATE(114)] = 1670,
  [SMALL_STATE(115)] = 1674,
  [SMALL_STATE(116)] = 1678,
  [SMALL_STATE(117)] = 1682,
  [SMALL_STATE(118)] = 1686,
  [SMALL_STATE(119)] = 1690,
  [SMALL_STATE(120)] = 1694,
  [SMALL_STATE(121)] = 1698,
  [SMALL_STATE(122)] = 1702,
  [SMALL_STATE(123)] = 1706,
  [SMALL_STATE(124)] = 1710,
  [SMALL_STATE(125)] = 1714,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 0),
  [5] = {.entry = {.count = 1, .reusable = true}}, SHIFT(16),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(93),
  [9] = {.entry = {.count = 1, .reusable = true}}, SHIFT(125),
  [11] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [13] = {.entry = {.count = 1, .reusable = true}}, SHIFT(97),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(122),
  [17] = {.entry = {.count = 1, .reusable = true}}, SHIFT(75),
  [19] = {.entry = {.count = 1, .reusable = true}}, SHIFT(74),
  [21] = {.entry = {.count = 1, .reusable = true}}, SHIFT(64),
  [23] = {.entry = {.count = 1, .reusable = false}}, SHIFT(64),
  [25] = {.entry = {.count = 1, .reusable = true}}, SHIFT(120),
  [27] = {.entry = {.count = 1, .reusable = true}}, SHIFT(14),
  [29] = {.entry = {.count = 1, .reusable = true}}, SHIFT(69),
  [31] = {.entry = {.count = 1, .reusable = true}}, SHIFT(83),
  [33] = {.entry = {.count = 1, .reusable = true}}, SHIFT(67),
  [35] = {.entry = {.count = 1, .reusable = true}}, SHIFT(63),
  [37] = {.entry = {.count = 1, .reusable = true}}, SHIFT(91),
  [39] = {.entry = {.count = 1, .reusable = true}}, SHIFT(57),
  [41] = {.entry = {.count = 1, .reusable = true}}, SHIFT(68),
  [43] = {.entry = {.count = 1, .reusable = true}}, SHIFT(87),
  [45] = {.entry = {.count = 1, .reusable = true}}, SHIFT(78),
  [47] = {.entry = {.count = 1, .reusable = true}}, SHIFT(85),
  [49] = {.entry = {.count = 1, .reusable = true}}, SHIFT(80),
  [51] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_comment, 1),
  [53] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_comment, 1),
  [55] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [57] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_comment_repeat1, 2),
  [59] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_comment_repeat1, 2),
  [61] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_comment_repeat1, 2), SHIFT_REPEAT(15),
  [64] = {.entry = {.count = 1, .reusable = true}}, SHIFT(65),
  [66] = {.entry = {.count = 1, .reusable = true}}, SHIFT(61),
  [68] = {.entry = {.count = 1, .reusable = true}}, SHIFT(73),
  [70] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string, 1),
  [72] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_string_repeat1, 2),
  [74] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_string_repeat1, 2), SHIFT_REPEAT(122),
  [77] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_line_string, 2),
  [79] = {.entry = {.count = 1, .reusable = true}}, SHIFT(52),
  [81] = {.entry = {.count = 1, .reusable = true}}, SHIFT(106),
  [83] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_quoted_string, 2),
  [85] = {.entry = {.count = 1, .reusable = true}}, SHIFT(56),
  [87] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_quoted_string, 3),
  [89] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 2),
  [91] = {.entry = {.count = 1, .reusable = true}}, SHIFT(34),
  [93] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [95] = {.entry = {.count = 1, .reusable = true}}, SHIFT(18),
  [97] = {.entry = {.count = 1, .reusable = true}}, SHIFT(50),
  [99] = {.entry = {.count = 1, .reusable = true}}, SHIFT(51),
  [101] = {.entry = {.count = 1, .reusable = true}}, SHIFT(54),
  [103] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 3),
  [105] = {.entry = {.count = 1, .reusable = true}}, SHIFT(41),
  [107] = {.entry = {.count = 1, .reusable = true}}, SHIFT(58),
  [109] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [111] = {.entry = {.count = 1, .reusable = true}}, SHIFT(66),
  [113] = {.entry = {.count = 1, .reusable = true}}, SHIFT(53),
  [115] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [117] = {.entry = {.count = 1, .reusable = true}}, SHIFT(71),
  [119] = {.entry = {.count = 1, .reusable = true}}, SHIFT(32),
  [121] = {.entry = {.count = 1, .reusable = true}}, SHIFT(43),
  [123] = {.entry = {.count = 1, .reusable = true}}, SHIFT(59),
  [125] = {.entry = {.count = 1, .reusable = true}}, SHIFT(33),
  [127] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 1),
  [129] = {.entry = {.count = 1, .reusable = true}}, SHIFT(40),
  [131] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_quoted_string_repeat1, 2),
  [133] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_quoted_string_repeat1, 2), SHIFT_REPEAT(49),
  [136] = {.entry = {.count = 2, .reusable = false}}, REDUCE(aux_sym_quoted_string_repeat1, 2), SHIFT_REPEAT(86),
  [139] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 3),
  [141] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6, .production_id = 1),
  [143] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3),
  [145] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5, .production_id = 1),
  [147] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5),
  [149] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6),
  [151] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 6),
  [153] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [155] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4, .production_id = 1),
  [157] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 7, .production_id = 1),
  [159] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 5),
  [161] = {.entry = {.count = 1, .reusable = false}}, SHIFT(28),
  [163] = {.entry = {.count = 1, .reusable = true}}, SHIFT(49),
  [165] = {.entry = {.count = 1, .reusable = false}}, SHIFT(86),
  [167] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 4),
  [169] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_integer, 1),
  [171] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 2),
  [173] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 3, .production_id = 1),
  [175] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 5),
  [177] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 6),
  [179] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 2),
  [181] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2),
  [183] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_top_level_struct_repeat1, 2), SHIFT_REPEAT(48),
  [186] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4),
  [188] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag_string, 5, .production_id = 4),
  [190] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 4),
  [192] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_float, 1),
  [194] = {.entry = {.count = 1, .reusable = false}}, SHIFT(25),
  [196] = {.entry = {.count = 1, .reusable = true}}, SHIFT(62),
  [198] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2), SHIFT_REPEAT(21),
  [201] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2),
  [203] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 4, .production_id = 3),
  [205] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2), SHIFT_REPEAT(5),
  [208] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2),
  [210] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 5, .production_id = 5),
  [212] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 2),
  [214] = {.entry = {.count = 1, .reusable = true}}, SHIFT(94),
  [216] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_name, 2),
  [218] = {.entry = {.count = 1, .reusable = true}}, SHIFT(88),
  [220] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array_elem, 1),
  [222] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 1),
  [224] = {.entry = {.count = 1, .reusable = true}}, SHIFT(81),
  [226] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map_field, 3, .production_id = 2),
  [228] = {.entry = {.count = 1, .reusable = true}}, SHIFT(92),
  [230] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map_field, 4, .production_id = 3),
  [232] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_struct_name_repeat1, 2),
  [234] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_struct_name_repeat1, 2), SHIFT_REPEAT(88),
  [237] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array_elem, 2),
  [239] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_escape_sequence, 2),
  [241] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_escape_sequence, 2),
  [243] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_name, 1),
  [245] = {.entry = {.count = 1, .reusable = true}}, SHIFT(82),
  [247] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2),
  [249] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_tag_repeat1, 2), SHIFT_REPEAT(94),
  [252] = {.entry = {.count = 1, .reusable = true}}, SHIFT(55),
  [254] = {.entry = {.count = 1, .reusable = true}}, SHIFT(60),
  [256] = {.entry = {.count = 1, .reusable = true}}, SHIFT(84),
  [258] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_top_level_struct, 4),
  [260] = {.entry = {.count = 1, .reusable = true}}, SHIFT(9),
  [262] = {.entry = {.count = 1, .reusable = true}}, SHIFT(124),
  [264] = {.entry = {.count = 1, .reusable = true}}, SHIFT(72),
  [266] = {.entry = {.count = 1, .reusable = true}}, SHIFT(37),
  [268] = {.entry = {.count = 1, .reusable = true}}, SHIFT(11),
  [270] = {.entry = {.count = 1, .reusable = true}}, SHIFT(12),
  [272] = {.entry = {.count = 1, .reusable = true}}, SHIFT(39),
  [274] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 1),
  [276] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [278] = {.entry = {.count = 1, .reusable = true}}, SHIFT(22),
  [280] = {.entry = {.count = 1, .reusable = true}}, SHIFT(13),
  [282] = {.entry = {.count = 1, .reusable = true}}, SHIFT(113),
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
