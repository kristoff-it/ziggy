#include "tree_sitter/parser.h"

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 13
#define STATE_COUNT 90
#define LARGE_STATE_COUNT 2
#define SYMBOL_COUNT 41
#define ALIAS_COUNT 1
#define TOKEN_COUNT 23
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 8
#define MAX_ALIAS_SEQUENCE_LENGTH 8
#define PRODUCTION_ID_COUNT 16

enum {
  sym_identifier = 1,
  anon_sym_root = 2,
  anon_sym_EQ = 3,
  anon_sym_COMMA = 4,
  anon_sym_AT = 5,
  anon_sym_enum = 6,
  anon_sym_LBRACE = 7,
  anon_sym_RBRACE = 8,
  anon_sym_bytes = 9,
  anon_sym_int = 10,
  anon_sym_float = 11,
  anon_sym_bool = 12,
  anon_sym_any = 13,
  anon_sym_unknown = 14,
  anon_sym_PIPE = 15,
  anon_sym_map = 16,
  anon_sym_LBRACK = 17,
  anon_sym_RBRACK = 18,
  anon_sym_QMARK = 19,
  anon_sym_struct = 20,
  anon_sym_COLON = 21,
  aux_sym_doc_comment_token1 = 22,
  sym_schema = 23,
  sym_tag_name = 24,
  sym_enum_definition = 25,
  sym_tag = 26,
  sym_expr = 27,
  sym_struct_union = 28,
  sym_map = 29,
  sym_array = 30,
  sym_optional = 31,
  sym_struct = 32,
  sym_struct_field = 33,
  sym_doc_comment = 34,
  aux_sym_schema_repeat1 = 35,
  aux_sym_schema_repeat2 = 36,
  aux_sym_enum_definition_repeat1 = 37,
  aux_sym_struct_union_repeat1 = 38,
  aux_sym_struct_repeat1 = 39,
  aux_sym_doc_comment_repeat1 = 40,
  anon_alias_sym__tag_name = 41,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [sym_identifier] = "identifier",
  [anon_sym_root] = "root",
  [anon_sym_EQ] = "=",
  [anon_sym_COMMA] = ",",
  [anon_sym_AT] = "@",
  [anon_sym_enum] = "enum",
  [anon_sym_LBRACE] = "{",
  [anon_sym_RBRACE] = "}",
  [anon_sym_bytes] = "bytes",
  [anon_sym_int] = "int",
  [anon_sym_float] = "float",
  [anon_sym_bool] = "bool",
  [anon_sym_any] = "any",
  [anon_sym_unknown] = "unknown",
  [anon_sym_PIPE] = "|",
  [anon_sym_map] = "map",
  [anon_sym_LBRACK] = "[",
  [anon_sym_RBRACK] = "]",
  [anon_sym_QMARK] = "\?",
  [anon_sym_struct] = "struct",
  [anon_sym_COLON] = ":",
  [aux_sym_doc_comment_token1] = "doc_comment_token1",
  [sym_schema] = "schema",
  [sym_tag_name] = "tag_name",
  [sym_enum_definition] = "enum_definition",
  [sym_tag] = "tag",
  [sym_expr] = "expr",
  [sym_struct_union] = "struct_union",
  [sym_map] = "map",
  [sym_array] = "array",
  [sym_optional] = "optional",
  [sym_struct] = "struct",
  [sym_struct_field] = "struct_field",
  [sym_doc_comment] = "doc_comment",
  [aux_sym_schema_repeat1] = "schema_repeat1",
  [aux_sym_schema_repeat2] = "schema_repeat2",
  [aux_sym_enum_definition_repeat1] = "enum_definition_repeat1",
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
  [anon_sym_enum] = anon_sym_enum,
  [anon_sym_LBRACE] = anon_sym_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
  [anon_sym_bytes] = anon_sym_bytes,
  [anon_sym_int] = anon_sym_int,
  [anon_sym_float] = anon_sym_float,
  [anon_sym_bool] = anon_sym_bool,
  [anon_sym_any] = anon_sym_any,
  [anon_sym_unknown] = anon_sym_unknown,
  [anon_sym_PIPE] = anon_sym_PIPE,
  [anon_sym_map] = anon_sym_map,
  [anon_sym_LBRACK] = anon_sym_LBRACK,
  [anon_sym_RBRACK] = anon_sym_RBRACK,
  [anon_sym_QMARK] = anon_sym_QMARK,
  [anon_sym_struct] = anon_sym_struct,
  [anon_sym_COLON] = anon_sym_COLON,
  [aux_sym_doc_comment_token1] = aux_sym_doc_comment_token1,
  [sym_schema] = sym_schema,
  [sym_tag_name] = sym_tag_name,
  [sym_enum_definition] = sym_enum_definition,
  [sym_tag] = sym_tag,
  [sym_expr] = sym_expr,
  [sym_struct_union] = sym_struct_union,
  [sym_map] = sym_map,
  [sym_array] = sym_array,
  [sym_optional] = sym_optional,
  [sym_struct] = sym_struct,
  [sym_struct_field] = sym_struct_field,
  [sym_doc_comment] = sym_doc_comment,
  [aux_sym_schema_repeat1] = aux_sym_schema_repeat1,
  [aux_sym_schema_repeat2] = aux_sym_schema_repeat2,
  [aux_sym_enum_definition_repeat1] = aux_sym_enum_definition_repeat1,
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
  [anon_sym_enum] = {
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
  [anon_sym_unknown] = {
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
  [anon_sym_QMARK] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_struct] = {
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
  [sym_tag_name] = {
    .visible = true,
    .named = true,
  },
  [sym_enum_definition] = {
    .visible = true,
    .named = true,
  },
  [sym_tag] = {
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
  [sym_optional] = {
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
  [aux_sym_enum_definition_repeat1] = {
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
  field_expr = 2,
  field_key = 3,
  field_name = 4,
  field_root = 5,
  field_structs = 6,
  field_tags = 7,
  field_value = 8,
};

static const char * const ts_field_names[] = {
  [0] = NULL,
  [field_docs] = "docs",
  [field_expr] = "expr",
  [field_key] = "key",
  [field_name] = "name",
  [field_root] = "root",
  [field_structs] = "structs",
  [field_tags] = "tags",
  [field_value] = "value",
};

static const TSFieldMapSlice ts_field_map_slices[PRODUCTION_ID_COUNT] = {
  [1] = {.index = 0, .length = 1},
  [3] = {.index = 1, .length = 2},
  [4] = {.index = 3, .length = 2},
  [5] = {.index = 5, .length = 3},
  [6] = {.index = 8, .length = 3},
  [7] = {.index = 11, .length = 2},
  [8] = {.index = 13, .length = 4},
  [9] = {.index = 17, .length = 4},
  [10] = {.index = 21, .length = 1},
  [11] = {.index = 22, .length = 5},
  [12] = {.index = 27, .length = 3},
  [13] = {.index = 30, .length = 2},
  [14] = {.index = 32, .length = 2},
  [15] = {.index = 34, .length = 3},
};

static const TSFieldMapEntry ts_field_map_entries[] = {
  [0] =
    {field_root, 2},
  [1] =
    {field_root, 2},
    {field_tags, 3},
  [3] =
    {field_root, 2},
    {field_structs, 3},
  [5] =
    {field_root, 2},
    {field_tags, 3},
    {field_tags, 4},
  [8] =
    {field_root, 2},
    {field_structs, 4},
    {field_tags, 3},
  [11] =
    {field_expr, 2},
    {field_name, 0},
  [13] =
    {field_root, 2},
    {field_structs, 5},
    {field_tags, 3},
    {field_tags, 4},
  [17] =
    {field_root, 2},
    {field_tags, 3},
    {field_tags, 4},
    {field_tags, 5},
  [21] =
    {field_name, 1},
  [22] =
    {field_root, 2},
    {field_structs, 6},
    {field_tags, 3},
    {field_tags, 4},
    {field_tags, 5},
  [27] =
    {field_docs, 0},
    {field_expr, 3},
    {field_name, 1},
  [30] =
    {field_docs, 0},
    {field_name, 2},
  [32] =
    {field_key, 0},
    {field_value, 2},
  [34] =
    {field_docs, 0},
    {field_key, 1},
    {field_value, 3},
};

static const TSSymbol ts_alias_sequences[PRODUCTION_ID_COUNT][MAX_ALIAS_SEQUENCE_LENGTH] = {
  [0] = {0},
  [2] = {
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
      if (lookahead == ':') ADVANCE(14);
      if (lookahead == '=') ADVANCE(4);
      if (lookahead == '?') ADVANCE(13);
      if (lookahead == '@') ADVANCE(6);
      if (lookahead == '[') ADVANCE(11);
      if (lookahead == ']') ADVANCE(12);
      if (lookahead == '{') ADVANCE(7);
      if (lookahead == '|') ADVANCE(9);
      if (lookahead == '}') ADVANCE(8);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(0)
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(10);
      END_STATE();
    case 1:
      if (lookahead == '/') ADVANCE(15);
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
      ACCEPT_TOKEN(anon_sym_LBRACE);
      END_STATE();
    case 8:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 9:
      ACCEPT_TOKEN(anon_sym_PIPE);
      END_STATE();
    case 10:
      ACCEPT_TOKEN(sym_identifier);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(10);
      END_STATE();
    case 11:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 12:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 13:
      ACCEPT_TOKEN(anon_sym_QMARK);
      END_STATE();
    case 14:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 15:
      ACCEPT_TOKEN(aux_sym_doc_comment_token1);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(15);
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
      if (lookahead == 'e') ADVANCE(3);
      if (lookahead == 'f') ADVANCE(4);
      if (lookahead == 'i') ADVANCE(5);
      if (lookahead == 'm') ADVANCE(6);
      if (lookahead == 'r') ADVANCE(7);
      if (lookahead == 's') ADVANCE(8);
      if (lookahead == 'u') ADVANCE(9);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(0)
      END_STATE();
    case 1:
      if (lookahead == 'n') ADVANCE(10);
      END_STATE();
    case 2:
      if (lookahead == 'o') ADVANCE(11);
      if (lookahead == 'y') ADVANCE(12);
      END_STATE();
    case 3:
      if (lookahead == 'n') ADVANCE(13);
      END_STATE();
    case 4:
      if (lookahead == 'l') ADVANCE(14);
      END_STATE();
    case 5:
      if (lookahead == 'n') ADVANCE(15);
      END_STATE();
    case 6:
      if (lookahead == 'a') ADVANCE(16);
      END_STATE();
    case 7:
      if (lookahead == 'o') ADVANCE(17);
      END_STATE();
    case 8:
      if (lookahead == 't') ADVANCE(18);
      END_STATE();
    case 9:
      if (lookahead == 'n') ADVANCE(19);
      END_STATE();
    case 10:
      if (lookahead == 'y') ADVANCE(20);
      END_STATE();
    case 11:
      if (lookahead == 'o') ADVANCE(21);
      END_STATE();
    case 12:
      if (lookahead == 't') ADVANCE(22);
      END_STATE();
    case 13:
      if (lookahead == 'u') ADVANCE(23);
      END_STATE();
    case 14:
      if (lookahead == 'o') ADVANCE(24);
      END_STATE();
    case 15:
      if (lookahead == 't') ADVANCE(25);
      END_STATE();
    case 16:
      if (lookahead == 'p') ADVANCE(26);
      END_STATE();
    case 17:
      if (lookahead == 'o') ADVANCE(27);
      END_STATE();
    case 18:
      if (lookahead == 'r') ADVANCE(28);
      END_STATE();
    case 19:
      if (lookahead == 'k') ADVANCE(29);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(anon_sym_any);
      END_STATE();
    case 21:
      if (lookahead == 'l') ADVANCE(30);
      END_STATE();
    case 22:
      if (lookahead == 'e') ADVANCE(31);
      END_STATE();
    case 23:
      if (lookahead == 'm') ADVANCE(32);
      END_STATE();
    case 24:
      if (lookahead == 'a') ADVANCE(33);
      END_STATE();
    case 25:
      ACCEPT_TOKEN(anon_sym_int);
      END_STATE();
    case 26:
      ACCEPT_TOKEN(anon_sym_map);
      END_STATE();
    case 27:
      if (lookahead == 't') ADVANCE(34);
      END_STATE();
    case 28:
      if (lookahead == 'u') ADVANCE(35);
      END_STATE();
    case 29:
      if (lookahead == 'n') ADVANCE(36);
      END_STATE();
    case 30:
      ACCEPT_TOKEN(anon_sym_bool);
      END_STATE();
    case 31:
      if (lookahead == 's') ADVANCE(37);
      END_STATE();
    case 32:
      ACCEPT_TOKEN(anon_sym_enum);
      END_STATE();
    case 33:
      if (lookahead == 't') ADVANCE(38);
      END_STATE();
    case 34:
      ACCEPT_TOKEN(anon_sym_root);
      END_STATE();
    case 35:
      if (lookahead == 'c') ADVANCE(39);
      END_STATE();
    case 36:
      if (lookahead == 'o') ADVANCE(40);
      END_STATE();
    case 37:
      ACCEPT_TOKEN(anon_sym_bytes);
      END_STATE();
    case 38:
      ACCEPT_TOKEN(anon_sym_float);
      END_STATE();
    case 39:
      if (lookahead == 't') ADVANCE(41);
      END_STATE();
    case 40:
      if (lookahead == 'w') ADVANCE(42);
      END_STATE();
    case 41:
      ACCEPT_TOKEN(anon_sym_struct);
      END_STATE();
    case 42:
      if (lookahead == 'n') ADVANCE(43);
      END_STATE();
    case 43:
      ACCEPT_TOKEN(anon_sym_unknown);
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
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [sym_identifier] = ACTIONS(1),
    [anon_sym_root] = ACTIONS(1),
    [anon_sym_EQ] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
    [anon_sym_AT] = ACTIONS(1),
    [anon_sym_enum] = ACTIONS(1),
    [anon_sym_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
    [anon_sym_bytes] = ACTIONS(1),
    [anon_sym_int] = ACTIONS(1),
    [anon_sym_float] = ACTIONS(1),
    [anon_sym_bool] = ACTIONS(1),
    [anon_sym_any] = ACTIONS(1),
    [anon_sym_unknown] = ACTIONS(1),
    [anon_sym_PIPE] = ACTIONS(1),
    [anon_sym_map] = ACTIONS(1),
    [anon_sym_LBRACK] = ACTIONS(1),
    [anon_sym_RBRACK] = ACTIONS(1),
    [anon_sym_QMARK] = ACTIONS(1),
    [anon_sym_struct] = ACTIONS(1),
    [anon_sym_COLON] = ACTIONS(1),
    [aux_sym_doc_comment_token1] = ACTIONS(1),
  },
  [1] = {
    [sym_schema] = STATE(86),
    [anon_sym_root] = ACTIONS(3),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 8,
    ACTIONS(5), 1,
      sym_identifier,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(11), 1,
      anon_sym_map,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_QMARK,
    STATE(66), 1,
      sym_expr,
    STATE(24), 5,
      sym_tag_name,
      sym_struct_union,
      sym_map,
      sym_array,
      sym_optional,
    ACTIONS(9), 6,
      anon_sym_bytes,
      anon_sym_int,
      anon_sym_float,
      anon_sym_bool,
      anon_sym_any,
      anon_sym_unknown,
  [34] = 8,
    ACTIONS(5), 1,
      sym_identifier,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(11), 1,
      anon_sym_map,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_QMARK,
    STATE(10), 1,
      sym_expr,
    STATE(24), 5,
      sym_tag_name,
      sym_struct_union,
      sym_map,
      sym_array,
      sym_optional,
    ACTIONS(9), 6,
      anon_sym_bytes,
      anon_sym_int,
      anon_sym_float,
      anon_sym_bool,
      anon_sym_any,
      anon_sym_unknown,
  [68] = 8,
    ACTIONS(5), 1,
      sym_identifier,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(11), 1,
      anon_sym_map,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_QMARK,
    STATE(67), 1,
      sym_expr,
    STATE(24), 5,
      sym_tag_name,
      sym_struct_union,
      sym_map,
      sym_array,
      sym_optional,
    ACTIONS(9), 6,
      anon_sym_bytes,
      anon_sym_int,
      anon_sym_float,
      anon_sym_bool,
      anon_sym_any,
      anon_sym_unknown,
  [102] = 8,
    ACTIONS(5), 1,
      sym_identifier,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(11), 1,
      anon_sym_map,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_QMARK,
    STATE(82), 1,
      sym_expr,
    STATE(24), 5,
      sym_tag_name,
      sym_struct_union,
      sym_map,
      sym_array,
      sym_optional,
    ACTIONS(9), 6,
      anon_sym_bytes,
      anon_sym_int,
      anon_sym_float,
      anon_sym_bool,
      anon_sym_any,
      anon_sym_unknown,
  [136] = 8,
    ACTIONS(5), 1,
      sym_identifier,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(11), 1,
      anon_sym_map,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_QMARK,
    STATE(18), 1,
      sym_expr,
    STATE(24), 5,
      sym_tag_name,
      sym_struct_union,
      sym_map,
      sym_array,
      sym_optional,
    ACTIONS(9), 6,
      anon_sym_bytes,
      anon_sym_int,
      anon_sym_float,
      anon_sym_bool,
      anon_sym_any,
      anon_sym_unknown,
  [170] = 8,
    ACTIONS(5), 1,
      sym_identifier,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(11), 1,
      anon_sym_map,
    ACTIONS(13), 1,
      anon_sym_LBRACK,
    ACTIONS(15), 1,
      anon_sym_QMARK,
    STATE(74), 1,
      sym_expr,
    STATE(24), 5,
      sym_tag_name,
      sym_struct_union,
      sym_map,
      sym_array,
      sym_optional,
    ACTIONS(9), 6,
      anon_sym_bytes,
      anon_sym_int,
      anon_sym_float,
      anon_sym_bool,
      anon_sym_any,
      anon_sym_unknown,
  [204] = 9,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(17), 1,
      ts_builtin_sym_end,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(43), 1,
      sym_tag,
    STATE(55), 1,
      sym_doc_comment,
    STATE(73), 1,
      sym_tag_name,
    STATE(25), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [233] = 9,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(23), 1,
      ts_builtin_sym_end,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(43), 1,
      sym_tag,
    STATE(55), 1,
      sym_doc_comment,
    STATE(73), 1,
      sym_tag_name,
    STATE(19), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [262] = 9,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(25), 1,
      ts_builtin_sym_end,
    STATE(14), 1,
      sym_tag,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(55), 1,
      sym_doc_comment,
    STATE(73), 1,
      sym_tag_name,
    STATE(20), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [291] = 8,
    ACTIONS(17), 1,
      ts_builtin_sym_end,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(27), 1,
      anon_sym_COMMA,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(37), 1,
      aux_sym_schema_repeat1,
    STATE(87), 1,
      sym_doc_comment,
    STATE(25), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [317] = 3,
    ACTIONS(31), 1,
      anon_sym_PIPE,
    STATE(15), 1,
      aux_sym_struct_union_repeat1,
    ACTIONS(29), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [333] = 3,
    ACTIONS(35), 1,
      anon_sym_PIPE,
    STATE(13), 1,
      aux_sym_struct_union_repeat1,
    ACTIONS(33), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [349] = 8,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(38), 1,
      ts_builtin_sym_end,
    ACTIONS(40), 1,
      anon_sym_COMMA,
    STATE(11), 1,
      aux_sym_schema_repeat1,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(87), 1,
      sym_doc_comment,
    STATE(26), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [375] = 3,
    ACTIONS(31), 1,
      anon_sym_PIPE,
    STATE(13), 1,
      aux_sym_struct_union_repeat1,
    ACTIONS(42), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [391] = 1,
    ACTIONS(33), 8,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACE,
      anon_sym_PIPE,
      anon_sym_RBRACK,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [402] = 1,
    ACTIONS(44), 8,
      ts_builtin_sym_end,
      anon_sym_EQ,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [413] = 1,
    ACTIONS(46), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [423] = 6,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(48), 1,
      ts_builtin_sym_end,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(87), 1,
      sym_doc_comment,
    STATE(23), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [443] = 6,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(50), 1,
      ts_builtin_sym_end,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(87), 1,
      sym_doc_comment,
    STATE(23), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [463] = 1,
    ACTIONS(52), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [473] = 1,
    ACTIONS(54), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [483] = 6,
    ACTIONS(56), 1,
      ts_builtin_sym_end,
    ACTIONS(58), 1,
      anon_sym_struct,
    ACTIONS(61), 1,
      aux_sym_doc_comment_token1,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(87), 1,
      sym_doc_comment,
    STATE(23), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [503] = 1,
    ACTIONS(29), 7,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_AT,
      anon_sym_RBRACE,
      anon_sym_RBRACK,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [513] = 6,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(64), 1,
      ts_builtin_sym_end,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(87), 1,
      sym_doc_comment,
    STATE(23), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [533] = 6,
    ACTIONS(19), 1,
      anon_sym_struct,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(66), 1,
      ts_builtin_sym_end,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(87), 1,
      sym_doc_comment,
    STATE(23), 2,
      sym_struct,
      aux_sym_schema_repeat2,
  [553] = 6,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(70), 1,
      anon_sym_RBRACE,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(61), 1,
      sym_struct_field,
    STATE(77), 1,
      sym_doc_comment,
  [572] = 6,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(43), 1,
      sym_tag,
    STATE(69), 1,
      sym_doc_comment,
    STATE(73), 1,
      sym_tag_name,
  [591] = 6,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(72), 1,
      anon_sym_RBRACE,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(68), 1,
      sym_struct_field,
    STATE(77), 1,
      sym_doc_comment,
  [610] = 6,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(74), 1,
      anon_sym_RBRACE,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(68), 1,
      sym_struct_field,
    STATE(77), 1,
      sym_doc_comment,
  [629] = 6,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(76), 1,
      anon_sym_RBRACE,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(68), 1,
      sym_struct_field,
    STATE(77), 1,
      sym_doc_comment,
  [648] = 6,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(78), 1,
      anon_sym_RBRACE,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(51), 1,
      sym_struct_field,
    STATE(77), 1,
      sym_doc_comment,
  [667] = 6,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    ACTIONS(80), 1,
      anon_sym_RBRACE,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(68), 1,
      sym_struct_field,
    STATE(77), 1,
      sym_doc_comment,
  [686] = 4,
    ACTIONS(84), 1,
      anon_sym_AT,
    ACTIONS(86), 1,
      aux_sym_doc_comment_token1,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    ACTIONS(82), 2,
      sym_identifier,
      anon_sym_struct,
  [700] = 5,
    ACTIONS(21), 1,
      aux_sym_doc_comment_token1,
    ACTIONS(68), 1,
      sym_identifier,
    STATE(34), 1,
      aux_sym_doc_comment_repeat1,
    STATE(68), 1,
      sym_struct_field,
    STATE(77), 1,
      sym_doc_comment,
  [716] = 4,
    ACTIONS(90), 1,
      anon_sym_AT,
    ACTIONS(92), 1,
      aux_sym_doc_comment_token1,
    STATE(36), 1,
      aux_sym_doc_comment_repeat1,
    ACTIONS(88), 2,
      sym_identifier,
      anon_sym_struct,
  [730] = 3,
    ACTIONS(97), 1,
      anon_sym_COMMA,
    STATE(37), 1,
      aux_sym_schema_repeat1,
    ACTIONS(95), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [742] = 1,
    ACTIONS(100), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [749] = 1,
    ACTIONS(102), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [756] = 1,
    ACTIONS(104), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [763] = 1,
    ACTIONS(106), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [770] = 1,
    ACTIONS(108), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [777] = 1,
    ACTIONS(95), 4,
      ts_builtin_sym_end,
      anon_sym_COMMA,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [784] = 3,
    ACTIONS(110), 1,
      anon_sym_COMMA,
    ACTIONS(112), 1,
      anon_sym_RBRACE,
    STATE(54), 1,
      aux_sym_enum_definition_repeat1,
  [794] = 1,
    ACTIONS(114), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [800] = 1,
    ACTIONS(116), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [806] = 1,
    ACTIONS(118), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [812] = 3,
    ACTIONS(120), 1,
      anon_sym_enum,
    ACTIONS(122), 1,
      anon_sym_bytes,
    STATE(38), 1,
      sym_enum_definition,
  [822] = 1,
    ACTIONS(124), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [828] = 3,
    ACTIONS(126), 1,
      anon_sym_COMMA,
    ACTIONS(129), 1,
      anon_sym_RBRACE,
    STATE(50), 1,
      aux_sym_enum_definition_repeat1,
  [838] = 3,
    ACTIONS(131), 1,
      anon_sym_COMMA,
    ACTIONS(133), 1,
      anon_sym_RBRACE,
    STATE(60), 1,
      aux_sym_struct_repeat1,
  [848] = 3,
    ACTIONS(80), 1,
      anon_sym_RBRACE,
    ACTIONS(135), 1,
      anon_sym_COMMA,
    STATE(57), 1,
      aux_sym_struct_repeat1,
  [858] = 1,
    ACTIONS(137), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [864] = 3,
    ACTIONS(139), 1,
      anon_sym_COMMA,
    ACTIONS(141), 1,
      anon_sym_RBRACE,
    STATE(50), 1,
      aux_sym_enum_definition_repeat1,
  [874] = 3,
    ACTIONS(7), 1,
      anon_sym_AT,
    ACTIONS(143), 1,
      anon_sym_struct,
    STATE(79), 1,
      sym_tag_name,
  [884] = 3,
    ACTIONS(120), 1,
      anon_sym_enum,
    ACTIONS(145), 1,
      anon_sym_bytes,
    STATE(42), 1,
      sym_enum_definition,
  [894] = 3,
    ACTIONS(147), 1,
      anon_sym_COMMA,
    ACTIONS(150), 1,
      anon_sym_RBRACE,
    STATE(57), 1,
      aux_sym_struct_repeat1,
  [904] = 1,
    ACTIONS(152), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [910] = 1,
    ACTIONS(154), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [916] = 3,
    ACTIONS(74), 1,
      anon_sym_RBRACE,
    ACTIONS(156), 1,
      anon_sym_COMMA,
    STATE(57), 1,
      aux_sym_struct_repeat1,
  [926] = 3,
    ACTIONS(158), 1,
      anon_sym_COMMA,
    ACTIONS(160), 1,
      anon_sym_RBRACE,
    STATE(52), 1,
      aux_sym_struct_repeat1,
  [936] = 1,
    ACTIONS(162), 3,
      ts_builtin_sym_end,
      anon_sym_struct,
      aux_sym_doc_comment_token1,
  [942] = 2,
    ACTIONS(141), 1,
      anon_sym_RBRACE,
    ACTIONS(164), 1,
      sym_identifier,
  [949] = 2,
    ACTIONS(164), 1,
      sym_identifier,
    ACTIONS(166), 1,
      anon_sym_RBRACE,
  [956] = 1,
    ACTIONS(129), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [961] = 1,
    ACTIONS(168), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [966] = 1,
    ACTIONS(170), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [971] = 1,
    ACTIONS(150), 2,
      anon_sym_COMMA,
      anon_sym_RBRACE,
  [976] = 2,
    ACTIONS(7), 1,
      anon_sym_AT,
    STATE(79), 1,
      sym_tag_name,
  [983] = 1,
    ACTIONS(172), 1,
      sym_identifier,
  [987] = 1,
    ACTIONS(174), 1,
      sym_identifier,
  [991] = 1,
    ACTIONS(176), 1,
      anon_sym_LBRACK,
  [995] = 1,
    ACTIONS(178), 1,
      anon_sym_EQ,
  [999] = 1,
    ACTIONS(180), 1,
      anon_sym_RBRACK,
  [1003] = 1,
    ACTIONS(182), 1,
      anon_sym_LBRACE,
  [1007] = 1,
    ACTIONS(184), 1,
      sym_identifier,
  [1011] = 1,
    ACTIONS(186), 1,
      sym_identifier,
  [1015] = 1,
    ACTIONS(188), 1,
      anon_sym_LBRACE,
  [1019] = 1,
    ACTIONS(190), 1,
      anon_sym_EQ,
  [1023] = 1,
    ACTIONS(192), 1,
      sym_identifier,
  [1027] = 1,
    ACTIONS(194), 1,
      sym_identifier,
  [1031] = 1,
    ACTIONS(196), 1,
      anon_sym_RBRACK,
  [1035] = 1,
    ACTIONS(198), 1,
      anon_sym_COLON,
  [1039] = 1,
    ACTIONS(200), 1,
      anon_sym_COLON,
  [1043] = 1,
    ACTIONS(202), 1,
      anon_sym_LBRACE,
  [1047] = 1,
    ACTIONS(204), 1,
      ts_builtin_sym_end,
  [1051] = 1,
    ACTIONS(143), 1,
      anon_sym_struct,
  [1055] = 1,
    ACTIONS(164), 1,
      sym_identifier,
  [1059] = 1,
    ACTIONS(206), 1,
      anon_sym_EQ,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(2)] = 0,
  [SMALL_STATE(3)] = 34,
  [SMALL_STATE(4)] = 68,
  [SMALL_STATE(5)] = 102,
  [SMALL_STATE(6)] = 136,
  [SMALL_STATE(7)] = 170,
  [SMALL_STATE(8)] = 204,
  [SMALL_STATE(9)] = 233,
  [SMALL_STATE(10)] = 262,
  [SMALL_STATE(11)] = 291,
  [SMALL_STATE(12)] = 317,
  [SMALL_STATE(13)] = 333,
  [SMALL_STATE(14)] = 349,
  [SMALL_STATE(15)] = 375,
  [SMALL_STATE(16)] = 391,
  [SMALL_STATE(17)] = 402,
  [SMALL_STATE(18)] = 413,
  [SMALL_STATE(19)] = 423,
  [SMALL_STATE(20)] = 443,
  [SMALL_STATE(21)] = 463,
  [SMALL_STATE(22)] = 473,
  [SMALL_STATE(23)] = 483,
  [SMALL_STATE(24)] = 503,
  [SMALL_STATE(25)] = 513,
  [SMALL_STATE(26)] = 533,
  [SMALL_STATE(27)] = 553,
  [SMALL_STATE(28)] = 572,
  [SMALL_STATE(29)] = 591,
  [SMALL_STATE(30)] = 610,
  [SMALL_STATE(31)] = 629,
  [SMALL_STATE(32)] = 648,
  [SMALL_STATE(33)] = 667,
  [SMALL_STATE(34)] = 686,
  [SMALL_STATE(35)] = 700,
  [SMALL_STATE(36)] = 716,
  [SMALL_STATE(37)] = 730,
  [SMALL_STATE(38)] = 742,
  [SMALL_STATE(39)] = 749,
  [SMALL_STATE(40)] = 756,
  [SMALL_STATE(41)] = 763,
  [SMALL_STATE(42)] = 770,
  [SMALL_STATE(43)] = 777,
  [SMALL_STATE(44)] = 784,
  [SMALL_STATE(45)] = 794,
  [SMALL_STATE(46)] = 800,
  [SMALL_STATE(47)] = 806,
  [SMALL_STATE(48)] = 812,
  [SMALL_STATE(49)] = 822,
  [SMALL_STATE(50)] = 828,
  [SMALL_STATE(51)] = 838,
  [SMALL_STATE(52)] = 848,
  [SMALL_STATE(53)] = 858,
  [SMALL_STATE(54)] = 864,
  [SMALL_STATE(55)] = 874,
  [SMALL_STATE(56)] = 884,
  [SMALL_STATE(57)] = 894,
  [SMALL_STATE(58)] = 904,
  [SMALL_STATE(59)] = 910,
  [SMALL_STATE(60)] = 916,
  [SMALL_STATE(61)] = 926,
  [SMALL_STATE(62)] = 936,
  [SMALL_STATE(63)] = 942,
  [SMALL_STATE(64)] = 949,
  [SMALL_STATE(65)] = 956,
  [SMALL_STATE(66)] = 961,
  [SMALL_STATE(67)] = 966,
  [SMALL_STATE(68)] = 971,
  [SMALL_STATE(69)] = 976,
  [SMALL_STATE(70)] = 983,
  [SMALL_STATE(71)] = 987,
  [SMALL_STATE(72)] = 991,
  [SMALL_STATE(73)] = 995,
  [SMALL_STATE(74)] = 999,
  [SMALL_STATE(75)] = 1003,
  [SMALL_STATE(76)] = 1007,
  [SMALL_STATE(77)] = 1011,
  [SMALL_STATE(78)] = 1015,
  [SMALL_STATE(79)] = 1019,
  [SMALL_STATE(80)] = 1023,
  [SMALL_STATE(81)] = 1027,
  [SMALL_STATE(82)] = 1031,
  [SMALL_STATE(83)] = 1035,
  [SMALL_STATE(84)] = 1039,
  [SMALL_STATE(85)] = 1043,
  [SMALL_STATE(86)] = 1047,
  [SMALL_STATE(87)] = 1051,
  [SMALL_STATE(88)] = 1055,
  [SMALL_STATE(89)] = 1059,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, SHIFT(89),
  [5] = {.entry = {.count = 1, .reusable = false}}, SHIFT(12),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(70),
  [9] = {.entry = {.count = 1, .reusable = false}}, SHIFT(24),
  [11] = {.entry = {.count = 1, .reusable = false}}, SHIFT(72),
  [13] = {.entry = {.count = 1, .reusable = true}}, SHIFT(5),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(6),
  [17] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 5, .production_id = 5),
  [19] = {.entry = {.count = 1, .reusable = true}}, SHIFT(71),
  [21] = {.entry = {.count = 1, .reusable = true}}, SHIFT(34),
  [23] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 6, .production_id = 9),
  [25] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 3, .production_id = 1),
  [27] = {.entry = {.count = 1, .reusable = true}}, SHIFT(9),
  [29] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_expr, 1),
  [31] = {.entry = {.count = 1, .reusable = true}}, SHIFT(80),
  [33] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_struct_union_repeat1, 2),
  [35] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_struct_union_repeat1, 2), SHIFT_REPEAT(80),
  [38] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 4, .production_id = 3),
  [40] = {.entry = {.count = 1, .reusable = true}}, SHIFT(8),
  [42] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_union, 2),
  [44] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag_name, 2, .production_id = 2),
  [46] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_optional, 2),
  [48] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 7, .production_id = 11),
  [50] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 4, .production_id = 4),
  [52] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 4),
  [54] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [56] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_schema_repeat2, 2),
  [58] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_schema_repeat2, 2), SHIFT_REPEAT(71),
  [61] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_schema_repeat2, 2), SHIFT_REPEAT(34),
  [64] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 6, .production_id = 8),
  [66] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_schema, 5, .production_id = 6),
  [68] = {.entry = {.count = 1, .reusable = true}}, SHIFT(84),
  [70] = {.entry = {.count = 1, .reusable = true}}, SHIFT(62),
  [72] = {.entry = {.count = 1, .reusable = true}}, SHIFT(46),
  [74] = {.entry = {.count = 1, .reusable = true}}, SHIFT(58),
  [76] = {.entry = {.count = 1, .reusable = true}}, SHIFT(45),
  [78] = {.entry = {.count = 1, .reusable = true}}, SHIFT(49),
  [80] = {.entry = {.count = 1, .reusable = true}}, SHIFT(47),
  [82] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_doc_comment, 1),
  [84] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_doc_comment, 1),
  [86] = {.entry = {.count = 1, .reusable = true}}, SHIFT(36),
  [88] = {.entry = {.count = 1, .reusable = false}}, REDUCE(aux_sym_doc_comment_repeat1, 2),
  [90] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_doc_comment_repeat1, 2),
  [92] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_doc_comment_repeat1, 2), SHIFT_REPEAT(36),
  [95] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_schema_repeat1, 2),
  [97] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_schema_repeat1, 2), SHIFT_REPEAT(28),
  [100] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 4, .production_id = 12),
  [102] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_enum_definition, 6),
  [104] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_enum_definition, 5),
  [106] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_enum_definition, 4),
  [108] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_tag, 3, .production_id = 7),
  [110] = {.entry = {.count = 1, .reusable = true}}, SHIFT(63),
  [112] = {.entry = {.count = 1, .reusable = true}}, SHIFT(41),
  [114] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 7, .production_id = 10),
  [116] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 8, .production_id = 13),
  [118] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 7, .production_id = 13),
  [120] = {.entry = {.count = 1, .reusable = true}}, SHIFT(78),
  [122] = {.entry = {.count = 1, .reusable = true}}, SHIFT(38),
  [124] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 4, .production_id = 10),
  [126] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_enum_definition_repeat1, 2), SHIFT_REPEAT(88),
  [129] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_enum_definition_repeat1, 2),
  [131] = {.entry = {.count = 1, .reusable = true}}, SHIFT(30),
  [133] = {.entry = {.count = 1, .reusable = true}}, SHIFT(59),
  [135] = {.entry = {.count = 1, .reusable = true}}, SHIFT(29),
  [137] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6, .production_id = 13),
  [139] = {.entry = {.count = 1, .reusable = true}}, SHIFT(64),
  [141] = {.entry = {.count = 1, .reusable = true}}, SHIFT(40),
  [143] = {.entry = {.count = 1, .reusable = true}}, SHIFT(81),
  [145] = {.entry = {.count = 1, .reusable = true}}, SHIFT(42),
  [147] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_struct_repeat1, 2), SHIFT_REPEAT(35),
  [150] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_struct_repeat1, 2),
  [152] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 6, .production_id = 10),
  [154] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5, .production_id = 10),
  [156] = {.entry = {.count = 1, .reusable = true}}, SHIFT(31),
  [158] = {.entry = {.count = 1, .reusable = true}}, SHIFT(33),
  [160] = {.entry = {.count = 1, .reusable = true}}, SHIFT(53),
  [162] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct, 5, .production_id = 13),
  [164] = {.entry = {.count = 1, .reusable = true}}, SHIFT(65),
  [166] = {.entry = {.count = 1, .reusable = true}}, SHIFT(39),
  [168] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 3, .production_id = 14),
  [170] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_struct_field, 4, .production_id = 15),
  [172] = {.entry = {.count = 1, .reusable = true}}, SHIFT(17),
  [174] = {.entry = {.count = 1, .reusable = true}}, SHIFT(75),
  [176] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [178] = {.entry = {.count = 1, .reusable = true}}, SHIFT(56),
  [180] = {.entry = {.count = 1, .reusable = true}}, SHIFT(21),
  [182] = {.entry = {.count = 1, .reusable = true}}, SHIFT(32),
  [184] = {.entry = {.count = 1, .reusable = true}}, SHIFT(44),
  [186] = {.entry = {.count = 1, .reusable = true}}, SHIFT(83),
  [188] = {.entry = {.count = 1, .reusable = true}}, SHIFT(76),
  [190] = {.entry = {.count = 1, .reusable = true}}, SHIFT(48),
  [192] = {.entry = {.count = 1, .reusable = true}}, SHIFT(16),
  [194] = {.entry = {.count = 1, .reusable = true}}, SHIFT(85),
  [196] = {.entry = {.count = 1, .reusable = true}}, SHIFT(22),
  [198] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [200] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [202] = {.entry = {.count = 1, .reusable = true}}, SHIFT(27),
  [204] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [206] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
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
