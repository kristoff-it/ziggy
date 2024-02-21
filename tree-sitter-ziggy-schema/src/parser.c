#include <tree_sitter/parser.h>

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 13
#define STATE_COUNT 72
#define LARGE_STATE_COUNT 7
#define SYMBOL_COUNT 35
#define ALIAS_COUNT 1
#define TOKEN_COUNT 20
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 7
#define MAX_ALIAS_SEQUENCE_LENGTH 8
#define PRODUCTION_ID_COUNT 16

enum {
  sym_identifier = 1,
  anon_sym_root = 2,
  anon_sym_EQ = 3,
  anon_sym_COMMA = 4,
  anon_sym_AT = 5,
  anon_sym_bytes = 6,
  anon_sym_int = 7,
  anon_sym_float = 8,
  anon_sym_bool = 9,
  anon_sym_any = 10,
  anon_sym_PIPE = 11,
  anon_sym_map = 12,
  anon_sym_LBRACK = 13,
  anon_sym_RBRACK = 14,
  anon_sym_struct = 15,
  anon_sym_LBRACE = 16,
  anon_sym_RBRACE = 17,
  anon_sym_COLON = 18,
  aux_sym_doc_comment_token1 = 19,
  sym_schema = 20,
  sym_tag = 21,
  sym_tag_name = 22,
  sym_expr = 23,
  sym_struct_union = 24,
  sym_map = 25,
  sym_array = 26,
  sym_struct = 27,
  sym_struct_field = 28,
  sym_doc_comment = 29,
  aux_sym_schema_repeat1 = 30,
  aux_sym_schema_repeat2 = 31,
  aux_sym_struct_union_repeat1 = 32,
  aux_sym_struct_repeat1 = 33,
  aux_sym_doc_comment_repeat1 = 34,
  anon_alias_sym__tag_name = 35,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [sym_identifier] = "identifier",
  [anon_sym_root] = "root",
  [anon_sym_EQ] = "=",
  [anon_sym_COMMA] = ",",
  [anon_sym_AT] = "@",
  [anon_sym_bytes] = "bytes",
  [anon_sym_int] = "int",
  [anon_sym_float] = "float",
  [anon_sym_bool] = "bool",
  [anon_sym_any] = "any",
  [anon_sym_PIPE] = "|",
  [anon_sym_map] = "map",
  [anon_sym_LBRACK] = "[",
  [anon_sym_RBRACK] = "]",
  [anon_sym_struct] = "struct",
  [anon_sym_LBRACE] = "{",
  [anon_sym_RBRACE] = "}",
  [anon_sym_COLON] = ":",
  [aux_sym_doc_comment_token1] = "doc_comment_token1",
  [sym_schema] = "schema",
  [sym_tag] = "tag",
  [sym_tag_name] = "tag_name",
  [sym_expr] = "expr",
  [sym_struct_union] = "struct_union",
  [sym_map] = "map",
  [sym_array] = "array",
  [sym_struct] = "struct",
  [sym_struct_field] = "struct_field",
  [sym_doc_comment] = "doc_comment",
  [aux_sym_schema_repeat1] = "schema_repeat1",
  [aux_sym_schema_repeat2] = "schema_repeat2",
  [aux_sym_struct_union_repeat1] = "struct_union_repeat1",
  [aux_sym_struct_repeat1] = "struct_repeat1",
  [aux_sym_doc_comment_repeat1] = "doc_comment_repeat1",
  [anon_alias_sym__tag_name] = "_tag_name",
};

static const TSSymbol ts_symbol_map[] = {
  [ts_builtin_sym_end] = ts_builtin_sym_end,
  [sym_identifier] = sym_identifier,
  [anon_sym_root] = anon_sym_root,
  [anon_sym_EQ] = anon_sym_EQ,
  [anon_sym_COMMA] = anon_sym_COMMA,
  [anon_sym_AT] = anon_sym_AT,
  [anon_sym_bytes] = anon_sym_bytes,
  [anon_sym_int] = anon_sym_int,
  [anon_sym_float] = anon_sym_float,
  [anon_sym_bool] = anon_sym_bool,
  [anon_sym_any] = anon_sym_any,
  [anon_sym_PIPE] = anon_sym_PIPE,
  [anon_sym_map] = anon_sym_map,
  [anon_sym_LBRACK] = anon_sym_LBRACK,
  [anon_sym_RBRACK] = anon_sym_RBRACK,
  [anon_sym_struct] = anon_sym_struct,
  [anon_sym_LBRACE] = anon_sym_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
  [anon_sym_COLON] = anon_sym_COLON,
  [aux_sym_doc_comment_token1] = aux_sym_doc_comment_token1,
  [sym_schema] = sym_schema,
  [sym_tag] = sym_tag,
  [sym_tag_name] = sym_tag_name,
  [sym_expr] = sym_expr,
  [sym_struct_union] = sym_struct_union,
  [sym_map] = sym_map,
  [sym_array] = sym_array,
  [sym_struct] = sym_struct,
  [sym_struct_field] = sym_struct_field,
  [sym_doc_comment] = sym_doc_comment,
  [aux_sym_schema_repeat1] = aux_sym_schema_repeat1,
  [aux_sym_schema_repeat2] = aux_sym_schema_repeat2,
  [aux_sym_struct_union_repeat1] = aux_sym_struct_union_repeat1,
  [aux_sym_struct_repeat1] = aux_sym_struct_repeat1,
  [aux_sym_doc_comment_repeat1] = aux_sym_doc_comment_repeat1,
  [anon_alias_sym__tag_name] = anon_alias_sym__tag_name,
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
  [anon_sym_root] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_EQ] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_COMMA] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_AT] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_bytes] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_int] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_float] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_bool] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_any] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_PIPE] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_map] = {
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
  [anon_sym_struct] = {
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
  [anon_sym_COLON] = {
    .visible = true,
    .named = false,
  },
  [aux_sym_doc_comment_token1] = {
    .visible = false,
    .named = false,
  },
  [sym_schema] = {
    .visible = true,
    .named = true,
  },
  [sym_tag] = {
    .visible = true,
    .named = true,
  },
  [sym_tag_name] = {
    .visible = true,
    .named = true,
  },
  [sym_expr] = {
    .visible = true,
    .named = true,
  },
  [sym_struct_union] = {
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
  [sym_struct] = {
    .visible = true,
    .named = true,
  },
  [sym_struct_field] = {
    .visible = true,
    .named = true,
  },
  [sym_doc_comment] = {
    .visible = true,
    .named = true,
  },
  [aux_sym_schema_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_schema_repeat2] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_struct_union_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_struct_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_doc_comment_repeat1] = {
    .visible = false,
    .named = false,
  },
  [anon_alias_sym__tag_name] = {
    .visible = true,
    .named = false,
  },
};

enum {
  field_docs = 1,
  field_key = 2,
  field_name = 3,
  field_root = 4,
  field_structs = 5,
  field_tags = 6,
  field_value = 7,
};

static const char * const ts_field_names[] = {
  [0] = NULL,
  [field_docs] = "docs",
  [field_key] = "key",
  [field_name] = "name",
  [field_root] = "root",
  [field_structs] = "structs",
  [field_tags] = "tags",
  [field_value] = "value",
};

static const TSFieldMapSlice ts_field_map_slices[PRODUCTION_ID_COUNT] = {
  [1] = {.index = 0, .length = 1},
  [2] = {.index = 1, .length = 1},
  [4] = {.index = 2, .length = 2},
  [5] = {.index = 4, .length = 2},
  [6] = {.index = 6, .length = 2},
  [7] = {.index = 8, .length = 3},
  [8] = {.index = 11, .length = 3},
  [9] = {.index = 14, .length = 4},
  [10] = {.index = 18, .length = 4},
  [11] = {.index = 22, .length = 1},
  [12] = {.index = 23, .length = 5},
  [13] = {.index = 28, .length = 2},
  [14] = {.index = 30, .length = 2},
  [15] = {.index = 32, .length = 3},
};

static const TSFieldMapEntry ts_field_map_entries[] = {
  [0] =
    {field_name, 0},
  [1] =
    {field_root, 2},
  [2] =
    {field_root, 2},
    {field_tags, 3},
  [4] =
    {field_root, 2},
    {field_structs, 3},
  [6] =
    {field_docs, 0},
    {field_name, 1},
  [8] =
    {field_root, 2},
    {field_tags, 3},
    {field_tags, 4},
  [11] =
    {field_root, 2},
    {field_structs, 4},
    {field_tags, 3},
  [14] =
    {field_root, 2},
    {field_structs, 5},
    {field_tags, 3},
    {field_tags, 4},
  [18] =
    {field_root, 2},
    {field_tags, 3},
    {field_tags, 4},
    {field_tags, 5},
  [22] =
    {field_name, 1},
  [23] =
    {field_root, 2},
    {field_structs, 6},
    {field_tags, 3},
    {field_tags, 4},
    {field_tags, 5},
  [28] =
    {field_docs, 0},
    {field_name, 2},
  [30] =
    {field_key, 0},
    {field_value, 2},
  [32] =
    {field_docs, 0},
    {field_key, 1},
    {field_value, 3},
};

static const TSSymbol ts_alias_sequences[PRODUCTION_ID_COUNT][MAX_ALIAS_SEQUENCE_LENGTH] = {
  [0] = {0},
  [3] = {
    [1] = anon_alias_sym__tag_name,
  },
};

static const uint16_t ts_non_terminal_alias_map[] = {
  0,
};

static bool ts_lex(TSLexer *lexer, TSStateId state) {
  START_LEXER();
  eof = lexer->eof(lexer);
  switch (state) {
    case 0:
      if (eof) ADVANCE(3);
      if (lookahead == ',') ADVANCE(5);
      if (lookahead == '/') ADVANCE(2);
      if (lookahead == ':') ADVANCE(13);
      if (lookahead == '=') ADVANCE(4);
      if (lookahead == '@') ADVANCE(6);
      if (lookahead == '[') ADVANCE(9);
      if (lookahead == ']') ADVANCE(10);
      if (lookahead == '{') ADVANCE(11);
      if (lookahead == '|') ADVANCE(7);
      if (lookahead == '}') ADVANCE(12);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(0)
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(8);
      END_STATE();
    case 1:
      if (lookahead == '/') ADVANCE(14);
      END_STATE();
    case 2:
      if (lookahead == '/') ADVANCE(1);
      END_STATE();
    case 3:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 4:
      ACCEPT_TOKEN(anon_sym_EQ);
      END_STATE();
    case 5:
      ACCEPT_TOKEN(anon_sym_COMMA);
      END_STATE();
    case 6:
      ACCEPT_TOKEN(anon_sym_AT);
      END_STATE();
    case 7:
      ACCEPT_TOKEN(anon_sym_PIPE);
      END_STATE();
    case 8:
      ACCEPT_TOKEN(sym_identifier);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(8);
      END_STATE();
    case 9:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 10:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 11:
      ACCEPT_TOKEN(anon_sym_LBRACE);
      END_STATE();
    case 12:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 13:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 14:
      ACCEPT_TOKEN(aux_sym_doc_comment_token1);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(14);
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
      if (lookahead == 'a') ADVANCE(1);
      if (lookahead == 'b') ADVANCE(2);
      if (lookahead == 'f') ADVANCE(3);
      if (lookahead == 'i') ADVANCE(4);
      if (lookahead == 'm') ADVANCE(5);
      if (lookahead == 'r') ADVANCE(6);
      if (lookahead == 's') ADVANCE(7);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(0)
      END_STATE();
    case 1:
      if (lookahead == 'n') ADVANCE(8);
      END_STATE();
    case 2:
      if (lookahead == 'o') ADVANCE(9);
      if (lookahead == 'y') ADVANCE(10);
      END_STATE();
    case 3:
      if (lookahead == 'l') ADVANCE(11);
      END_STATE();
    case 4:
      if (lookahead == 'n') ADVANCE(12);
      END_STATE();
    case 5:
      if (lookahead == 'a') ADVANCE(13);
      END_STATE();
    case 6:
      if (lookahead == 'o') ADVANCE(14);
      END_STATE();
    case 7:
      if (lookahead == 't') ADVANCE(15);
      END_STATE();
    case 8:
      if (lookahead == 'y') ADVANCE(16);
      END_STATE();
    case 9:
      if (lookahead == 'o') ADVANCE(17);
      END_STATE();
    case 10:
      if (lookahead == 't') ADVANCE(18);
      END_STATE();
    case 11:
      if (lookahead == 'o') ADVANCE(19);
      END_STATE();
    case 12:
      if (lookahead == 't') ADVANCE(20);
      END_STATE();
    case 13:
      if (lookahead == 'p') ADVANCE(21);
      END_STATE();
    case 14:
      if (lookahead == 'o') ADVANCE(22);
      END_STATE();
    case 15:
      if (lookahead == 'r') ADVANCE(23);
      END_STATE();
    case 16:
      ACCEPT_TOKEN(anon_sym_any);
      END_STATE();
    case 17:
      if (lookahead == 'l') ADVANCE(24);
      END_STATE();
    case 18:
      if (lookahead == 'e') ADVANCE(25);
      END_STATE();
    case 19:
      if (lookahead == 'a') ADVANCE(26);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(anon_sym_int);
      END_STATE();
    case 21:
      ACCEPT_TOKEN(anon_sym_map);
      END_STATE();
    case 22:
      if (lookahead == 't') ADVANCE(27);
      END_STATE();
    case 23:
      if (lookahead == 'u') ADVANCE(28);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(anon_sym_bool);
      END_STATE();
    case 25:
      if (lookahead == 's') ADVANCE(29);
      END_STATE();
    case 26:
      if (lookahead == 't') ADVANCE(30);
      END_STATE();
    case 27:
      ACCEPT_TOKEN(anon_sym_root);
      END_STATE();
    case 28:
      if (lookahead == 'c') ADVANCE(31);
      END_STATE();
    case 29:
      ACCEPT_TOKEN(anon_sym_bytes);
      END_STATE();
    case 30:
      ACCEPT_TOKEN(anon_sym_float);
      END_STATE();
    case 31:
      if (lookahead == 't') ADVANCE(32);
      END_STATE();
    case 32:
      ACCEPT_TOKEN(anon_sym_struct);
      END_STATE();
    default:
      return false;
  }
}

static const TSLexMode ts_lex_modes[STATE_COUNT] = {
  [0] = {.lex_state = 0},
  [1] = {.lex_state = 0},
  [2] = {.lex_state = 0},
  [3] = {.lex_state = 0},
  [4] = {.lex_state = 0},
  [5] = {.lex_state = 0},
  [6] = {.lex_state = 0},
  [7] = {.lex_state = 0},
  [8] = {.lex_state = 0},
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
  [61] = {.lex_state = 0},
  [62] = {.lex_state = 0},
  [63] = {.lex_state = 0},
  [64] = {.lex_state = 0},
  [65] = {.lex_state = 0},
  [66] = {.lex_state = 0},
  [67] = {.lex_state = 0},
  [68] = {.lex_state = 0},
  [69] = {.lex_state = 0},
  [70] = {.lex_state = 0},
  [71] = {.lex_state = 0},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [sym_identifier] = ACTIONS(1),
    [anon_sym_root] = ACTIONS(1),
    [anon_sym_EQ] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
    [anon_sym_AT] = ACTIONS(1),
    [anon_sym_bytes] = ACTIONS(1),
    [anon_sym_int] = ACTIONS(1),
    [anon_sym_float] = ACTIONS(1),
    [anon_sym_bool] = ACTIONS(1),
    [anon_sym_any] = ACTIONS(1),
    [anon_sym_PIPE] = ACTIONS(1),
    [anon_sym_map] = ACTIONS(1),
    [anon_sym_LBRACK] = ACTIONS(1),
    [anon_sym_RBRACK] = ACTIONS(1),
    [anon_sym_struct] = ACTIONS(1),
    [anon_sym_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
    [anon_sym_COLON] = ACTIONS(1),
    [aux_sym_doc_comment_token1] = ACTIONS(1),
  },
  [1] = {
    [sym_schema] = STATE(70),
    [anon_sym_root] = ACTIONS(3),
  },
  [2] = {
    [sym_tag] = STATE(23),
    [sym_tag_name] = STATE(20),
    [sym_expr] = STATE(60),
    [sym_struct_union] = STATE(23),
    [sym_map] = STATE(23),
    [sym_array] = STATE(23),
    [sym_doc_comment] = STATE(55),
    [aux_sym_doc_comment_repeat1] = STATE(36),
    [sym_identifier] = ACTIONS(5),
    [anon_sym_AT] = ACTIONS(7),
    [anon_sym_bytes] = ACTIONS(9),
    [anon_sym_int] = ACTIONS(9),
    [anon_sym_float] = ACTIONS(9),
    [anon_sym_bool] = ACTIONS(9),
    [anon_sym_any] = ACTIONS(9),
    [anon_sym_map] = ACTIONS(11),
    [anon_sym_LBRACK] = ACTIONS(13),
    [aux_sym_doc_comment_token1] = ACTIONS(15),
  },
  [3] = {
    [sym_tag] = STATE(23),
    [sym_tag_name] = STATE(20),
    [sym_expr] = STATE(8),
    [sym_struct_union] = STATE(23),
    [sym_map] = STATE(23),
    [sym_array] = STATE(23),
    [sym_doc_comment] = STATE(55),
    [aux_sym_doc_comment_repeat1] = STATE(36),
    [sym_identifier] = ACTIONS(5),
    [anon_sym_AT] = ACTIONS(7),
    [anon_sym_bytes] = ACTIONS(9),
    [anon_sym_int] = ACTIONS(9),
    [anon_sym_float] = ACTIONS(9),
    [anon_sym_bool] = ACTIONS(9),
    [anon_sym_any] = ACTIONS(9),
    [anon_sym_map] = ACTIONS(11),
    [anon_sym_LBRACK] = ACTIONS(13),
    [aux_sym_doc_comment_token1] = ACTIONS(15),
  },
  [4] = {
    [sym_tag] = STATE(23),
    [sym_tag_name] = STATE(20),
    [sym_expr] = STATE(56),
    [sym_struct_union] = STATE(23),
    [sym_map] = STATE(23),
    [sym_array] = STATE(23),
    [sym_doc_comment] = STATE(55),
    [aux_sym_doc_comment_repeat1] = STATE(36),
    [sym_identifier] = ACTIONS(5),
    [anon_sym_AT] = ACTIONS(7),
    [anon_sym_bytes] = ACTIONS(9),
    [anon_sym_int] = ACTIONS(9),
    [anon_sym_float] = ACTIONS(9),
    [anon_sym_bool] = ACTIONS(9),
    [anon_sym_any] = ACTIONS(9),
    [anon_sym_map] = ACTIONS(11),
    [anon_sym_LBRACK] = ACTIONS(13),
    [aux_sym_doc_comment_token1] = ACTIONS(15),
  },
  [5] = {
    [sym_tag] = STATE(23),
    [sym_tag_name] = STATE(20),
    [sym_expr] = STATE(59),
    [sym_struct_union] = STATE(23),
    [sym_map] = STATE(23),
    [sym_array] = STATE(23),
    [sym_doc_comment] = STATE(55),
    [aux_sym_doc_comment_repeat1] = STATE(36),
    [sym_identifier] = ACTIONS(5),
    [anon_sym_AT] = ACTIONS(7),
    [anon_sym_bytes] = ACTIONS(9),
    [anon_sym_int] = ACTIONS(9),
    [anon_sym_float] = ACTIONS(9),
    [anon_sym_bool] = ACTIONS(9),
    [anon_sym_any] = ACTIONS(9),
    [anon_sym_map] = ACTIONS(11),
    [anon_sym_LBRACK] = ACTIONS(13),
    [aux_sym_doc_comment_token1] = ACTIONS(15),
  },
  [6] = {
    [sym_tag] = STATE(23),
    [sym_tag_name] = STATE(20),
    [sym_expr] = STATE(53),
    [sym_struct_union] = STATE(23),
    [sym_map] = STATE(23),
    [sym_array] = STATE(23),
    [sym_doc_comment] = STATE(55),
    [aux_sym_doc_comment_repeat1] = STATE(36),
    [sym_identifier] = ACTIONS(5),
    [anon_sym_AT] = ACTIONS(7),
    [anon_sym_bytes] = ACTIONS(9),
    [anon_sym_int] = ACTIONS(9),
    [anon_sym_float] = ACTIONS(9),
    [anon_sym_bool] = ACTIONS(9),
    [anon_sym_any] = ACTIONS(9),
    [anon_sym_map] = ACTIONS(11),
    [anon_sym_LBRACK] = ACTIONS(13),
    [aux_sym_doc_comment_token1] = ACTIONS(15),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 9,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(17), 1,
      ts_builtin_sym_end,
    ACTIONS(19), 1,
      anon_sym_struct,
    STATE(20), 1,
      sym_tag_name,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(38), 1,
      sym_tag,
    STATE(50), 1,
      sym_doc_comment,
    STATE(26), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [29] = 9,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      ts_builtin_sym_end,
    STATE(11), 1,
      sym_tag,
    STATE(20), 1,
      sym_tag_name,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(50), 1,
      sym_doc_comment,
    STATE(21), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [58] = 9,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(23), 1,
      ts_builtin_sym_end,
    STATE(20), 1,
      sym_tag_name,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(38), 1,
      sym_tag,
    STATE(50), 1,
      sym_doc_comment,
    STATE(18), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [87] = 3,
    ACTIONS(27), 1,
      anon_sym_PIPE,
    STATE(10), 1,
      aux_sym_struct_union_repeat1,
    ACTIONS(25), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [103] = 8,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(30), 1,
      ts_builtin_sym_end,
    ACTIONS(32), 1,
      anon_sym_COMMA,
    STATE(13), 1,
      aux_sym_schema_repeat1,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(63), 1,
      sym_doc_comment,
    STATE(16), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [129] = 3,
    ACTIONS(36), 1,
      anon_sym_PIPE,
    STATE(14), 1,
      aux_sym_struct_union_repeat1,
    ACTIONS(34), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [145] = 8,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(23), 1,
      ts_builtin_sym_end,
    ACTIONS(38), 1,
      anon_sym_COMMA,
    STATE(35), 1,
      aux_sym_schema_repeat1,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(63), 1,
      sym_doc_comment,
    STATE(18), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [171] = 3,
    ACTIONS(36), 1,
      anon_sym_PIPE,
    STATE(10), 1,
      aux_sym_struct_union_repeat1,
    ACTIONS(40), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [187] = 1,
    ACTIONS(25), 8,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_PIPE,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [198] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(42), 1,
      ts_builtin_sym_end,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(63), 1,
      sym_doc_comment,
    STATE(24), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [218] = 1,
    ACTIONS(44), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [228] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(46), 1,
      ts_builtin_sym_end,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(63), 1,
      sym_doc_comment,
    STATE(24), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [248] = 1,
    ACTIONS(48), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [258] = 1,
    ACTIONS(50), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [268] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(52), 1,
      ts_builtin_sym_end,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(63), 1,
      sym_doc_comment,
    STATE(24), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [288] = 1,
    ACTIONS(54), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [298] = 1,
    ACTIONS(34), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [308] = 6,
    ACTIONS(56), 1,
      ts_builtin_sym_end,
    ACTIONS(58), 1,
      anon_sym_struct,
    ACTIONS(61), 1,
      aux_sym_doc_comment_token1,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(63), 1,
      sym_doc_comment,
    STATE(24), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [328] = 1,
    ACTIONS(64), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACK,
      anon_sym_struct,
      anon_sym_RBRACE,
      aux_sym_doc_comment_token1,
  [338] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(66), 1,
      ts_builtin_sym_end,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(63), 1,
      sym_doc_comment,
    STATE(24), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [358] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(70), 1,
      anon_sym_RBRACE,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(54), 1,
      sym_struct_field,
    STATE(66), 1,
      sym_doc_comment,
  [377] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(72), 1,
      anon_sym_RBRACE,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(49), 1,
      sym_struct_field,
    STATE(66), 1,
      sym_doc_comment,
  [396] = 6,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    STATE(20), 1,
      sym_tag_name,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(38), 1,
      sym_tag,
    STATE(55), 1,
      sym_doc_comment,
  [415] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(74), 1,
      anon_sym_RBRACE,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(54), 1,
      sym_struct_field,
    STATE(66), 1,
      sym_doc_comment,
  [434] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(76), 1,
      anon_sym_RBRACE,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(54), 1,
      sym_struct_field,
    STATE(66), 1,
      sym_doc_comment,
  [453] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(78), 1,
      anon_sym_RBRACE,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(54), 1,
      sym_struct_field,
    STATE(66), 1,
      sym_doc_comment,
  [472] = 6,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(80), 1,
      anon_sym_RBRACE,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(45), 1,
      sym_struct_field,
    STATE(66), 1,
      sym_doc_comment,
  [491] = 4,
    ACTIONS(84), 1,
      anon_sym_AT,
    ACTIONS(86), 1,
      aux_sym_doc_comment_token1,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    ACTIONS(82), 2,
      sym_identifier,
      anon_sym_struct,
  [505] = 3,
    ACTIONS(91), 1,
      anon_sym_COMMA,
    STATE(35), 1,
      aux_sym_schema_repeat1,
    ACTIONS(89), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [517] = 4,
    ACTIONS(96), 1,
      anon_sym_AT,
    ACTIONS(98), 1,
      aux_sym_doc_comment_token1,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    ACTIONS(94), 2,
      sym_identifier,
      anon_sym_struct,
  [531] = 5,
    ACTIONS(15), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    STATE(54), 1,
      sym_struct_field,
    STATE(66), 1,
      sym_doc_comment,
  [547] = 1,
    ACTIONS(89), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [554] = 1,
    ACTIONS(100), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [560] = 1,
    ACTIONS(102), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [566] = 1,
    ACTIONS(104), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [572] = 1,
    ACTIONS(106), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [578] = 1,
    ACTIONS(108), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [584] = 1,
    ACTIONS(110), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [590] = 3,
    ACTIONS(112), 1,
      anon_sym_COMMA,
    ACTIONS(114), 1,
      anon_sym_RBRACE,
    STATE(51), 1,
      aux_sym_struct_repeat1,
  [600] = 3,
    ACTIONS(78), 1,
      anon_sym_RBRACE,
    ACTIONS(116), 1,
      anon_sym_COMMA,
    STATE(47), 1,
      aux_sym_struct_repeat1,
  [610] = 3,
    ACTIONS(118), 1,
      anon_sym_COMMA,
    ACTIONS(121), 1,
      anon_sym_RBRACE,
    STATE(47), 1,
      aux_sym_struct_repeat1,
  [620] = 1,
    ACTIONS(123), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [626] = 3,
    ACTIONS(125), 1,
      anon_sym_COMMA,
    ACTIONS(127), 1,
      anon_sym_RBRACE,
    STATE(46), 1,
      aux_sym_struct_repeat1,
  [636] = 3,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(129), 1,
      anon_sym_struct,
    STATE(22), 1,
      sym_tag_name,
  [646] = 3,
    ACTIONS(70), 1,
      anon_sym_RBRACE,
    ACTIONS(131), 1,
      anon_sym_COMMA,
    STATE(47), 1,
      aux_sym_struct_repeat1,
  [656] = 1,
    ACTIONS(133), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [662] = 1,
    ACTIONS(135), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [667] = 1,
    ACTIONS(121), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [672] = 2,
    ACTIONS(7), 1,
      anon_sym_AT,
    STATE(22), 1,
      sym_tag_name,
  [679] = 1,
    ACTIONS(137), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [684] = 1,
    ACTIONS(139), 1,
      sym_identifier,
  [688] = 1,
    ACTIONS(141), 1,
      anon_sym_COLON,
  [692] = 1,
    ACTIONS(143), 1,
      anon_sym_RBRACK,
  [696] = 1,
    ACTIONS(145), 1,
      anon_sym_RBRACK,
  [700] = 1,
    ACTIONS(147), 1,
      anon_sym_LBRACE,
  [704] = 1,
    ACTIONS(149), 1,
      sym_identifier,
  [708] = 1,
    ACTIONS(129), 1,
      anon_sym_struct,
  [712] = 1,
    ACTIONS(151), 1,
      anon_sym_LBRACK,
  [716] = 1,
    ACTIONS(153), 1,
      anon_sym_EQ,
  [720] = 1,
    ACTIONS(155), 1,
      sym_identifier,
  [724] = 1,
    ACTIONS(157), 1,
      anon_sym_COLON,
  [728] = 1,
    ACTIONS(159), 1,
      sym_identifier,
  [732] = 1,
    ACTIONS(161), 1,
      anon_sym_LBRACE,
  [736] = 1,
    ACTIONS(163), 1,
      ts_builtin_sym_end,
  [740] = 1,
    ACTIONS(165), 1,
      sym_identifier,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(7)] = 0,
  [SMALL_STATE(8)] = 29,
  [SMALL_STATE(9)] = 58,
  [SMALL_STATE(10)] = 87,
  [SMALL_STATE(11)] = 103,
  [SMALL_STATE(12)] = 129,
  [SMALL_STATE(13)] = 145,
  [SMALL_STATE(14)] = 171,
  [SMALL_STATE(15)] = 187,
  [SMALL_STATE(16)] = 198,
  [SMALL_STATE(17)] = 218,
  [SMALL_STATE(18)] = 228,
  [SMALL_STATE(19)] = 248,
  [SMALL_STATE(20)] = 258,
  [SMALL_STATE(21)] = 268,
  [SMALL_STATE(22)] = 288,
  [SMALL_STATE(23)] = 298,
  [SMALL_STATE(24)] = 308,
  [SMALL_STATE(25)] = 328,
  [SMALL_STATE(26)] = 338,
  [SMALL_STATE(27)] = 358,
  [SMALL_STATE(28)] = 377,
  [SMALL_STATE(29)] = 396,
  [SMALL_STATE(30)] = 415,
  [SMALL_STATE(31)] = 434,
  [SMALL_STATE(32)] = 453,
  [SMALL_STATE(33)] = 472,
  [SMALL_STATE(34)] = 491,
  [SMALL_STATE(35)] = 505,
  [SMALL_STATE(36)] = 517,
  [SMALL_STATE(37)] = 531,
  [SMALL_STATE(38)] = 547,
  [SMALL_STATE(39)] = 554,
  [SMALL_STATE(40)] = 560,
  [SMALL_STATE(41)] = 566,
  [SMALL_STATE(42)] = 572,
  [SMALL_STATE(43)] = 578,
  [SMALL_STATE(44)] = 584,
  [SMALL_STATE(45)] = 590,
  [SMALL_STATE(46)] = 600,
  [SMALL_STATE(47)] = 610,
  [SMALL_STATE(48)] = 620,
  [SMALL_STATE(49)] = 626,
  [SMALL_STATE(50)] = 636,
  [SMALL_STATE(51)] = 646,
  [SMALL_STATE(52)] = 656,
  [SMALL_STATE(53)] = 662,
  [SMALL_STATE(54)] = 667,
  [SMALL_STATE(55)] = 672,
  [SMALL_STATE(56)] = 679,
  [SMALL_STATE(57)] = 684,
  [SMALL_STATE(58)] = 688,
  [SMALL_STATE(59)] = 692,
  [SMALL_STATE(60)] = 696,
  [SMALL_STATE(61)] = 700,
  [SMALL_STATE(62)] = 704,
  [SMALL_STATE(63)] = 708,
  [SMALL_STATE(64)] = 712,
  [SMALL_STATE(65)] = 716,
  [SMALL_STATE(66)] = 720,
  [SMALL_STATE(67)] = 724,
  [SMALL_STATE(68)] = 728,
  [SMALL_STATE(69)] = 732,
  [SMALL_STATE(70)] = 736,
  [SMALL_STATE(71)] = 740,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, SHIFT(65),
  [5] = {.entry = {.count = 1, .reusable = false}}, SHIFT(12),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(68),
  [9] = {.entry = {.count = 1, .reusable = false}}, SHIFT(23),
  [11] = {.entry = {.count = 1, .reusable = false}}, SHIFT(64),
  [13] = {.entry = {.count = 1, .reusable = true}}, SHIFT(5),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(36),
  [17] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 6, .production_id = 10),
  [19] = {.entry = {.count = 1, .reusable = true}}, SHIFT(57),
  [21] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 3, .production_id = 2),
  [23] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 5, .production_id = 7),
  [25] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_struct_union_repeat1, 2),
  [27] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_struct_union_repeat1, 2), SHIFT_REPEAT(62),
  [30] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 4, .production_id = 4),
  [32] = {.entry = {.count = 1, .reusable = true}}, SHIFT(9),
  [34] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_expr, 1),
  [36] = {.entry = {.count = 1, .reusable = true}}, SHIFT(62),
  [38] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [40] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_union, 2),
  [42] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 5, .production_id = 8),
  [44] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag_name, 2, .production_id = 3),
  [46] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 6, .production_id = 9),
  [48] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 4),
  [50] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 1, .production_id = 1),
  [52] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 4, .production_id = 5),
  [54] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 2, .production_id = 6),
  [56] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_schema_repeat2, 2),
  [58] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_schema_repeat2, 2), SHIFT_REPEAT(57),
  [61] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_schema_repeat2, 2), SHIFT_REPEAT(36),
  [64] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [66] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 7, .production_id = 12),
  [68] = {.entry = {.count = 1, .reusable = true}}, SHIFT(67),
  [70] = {.entry = {.count = 1, .reusable = true}}, SHIFT(48),
  [72] = {.entry = {.count = 1, .reusable = true}}, SHIFT(39),
  [74] = {.entry = {.count = 1, .reusable = true}}, SHIFT(41),
  [76] = {.entry = {.count = 1, .reusable = true}}, SHIFT(43),
  [78] = {.entry = {.count = 1, .reusable = true}}, SHIFT(42),
  [80] = {.entry = {.count = 1, .reusable = true}}, SHIFT(44),
  [82] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_doc_comment_repeat1, 2),
  [84] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_doc_comment_repeat1, 2),
  [86] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_doc_comment_repeat1, 2), SHIFT_REPEAT(34),
  [89] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_schema_repeat1, 2),
  [91] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_schema_repeat1, 2), SHIFT_REPEAT(29),
  [94] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_doc_comment, 1),
  [96] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_doc_comment, 1),
  [98] = {.entry = {.count = 1, .reusable = true}}, SHIFT(34),
  [100] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5, .production_id = 13),
  [102] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6, .production_id = 13),
  [104] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 8, .production_id = 13),
  [106] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 7, .production_id = 13),
  [108] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 7, .production_id = 11),
  [110] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4, .production_id = 11),
  [112] = {.entry = {.count = 1, .reusable = true}}, SHIFT(27),
  [114] = {.entry = {.count = 1, .reusable = true}}, SHIFT(52),
  [116] = {.entry = {.count = 1, .reusable = true}}, SHIFT(30),
  [118] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_struct_repeat1, 2), SHIFT_REPEAT(37),
  [121] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_struct_repeat1, 2),
  [123] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6, .production_id = 11),
  [125] = {.entry = {.count = 1, .reusable = true}}, SHIFT(32),
  [127] = {.entry = {.count = 1, .reusable = true}}, SHIFT(40),
  [129] = {.entry = {.count = 1, .reusable = true}}, SHIFT(71),
  [131] = {.entry = {.count = 1, .reusable = true}}, SHIFT(31),
  [133] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5, .production_id = 11),
  [135] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 3, .production_id = 14),
  [137] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 4, .production_id = 15),
  [139] = {.entry = {.count = 1, .reusable = true}}, SHIFT(61),
  [141] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [143] = {.entry = {.count = 1, .reusable = true}}, SHIFT(25),
  [145] = {.entry = {.count = 1, .reusable = true}}, SHIFT(19),
  [147] = {.entry = {.count = 1, .reusable = true}}, SHIFT(33),
  [149] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [151] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [153] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [155] = {.entry = {.count = 1, .reusable = true}}, SHIFT(58),
  [157] = {.entry = {.count = 1, .reusable = true}}, SHIFT(6),
  [159] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [161] = {.entry = {.count = 1, .reusable = true}}, SHIFT(28),
  [163] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [165] = {.entry = {.count = 1, .reusable = true}}, SHIFT(69),
};

#ifdef __cplusplus
extern "C" {
#endif
#ifdef _WIN32
#define extern __declspec(dllexport)
#endif

extern const TSLanguage *tree_sitter_ziggy_schema(void) {
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
  };
  return &language;
}
#ifdef __cplusplus
}
#endif
