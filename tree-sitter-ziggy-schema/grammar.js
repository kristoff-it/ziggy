/* eslint-disable 80001 */
/* eslint-disable arrow-parens */
/* eslint-disable camelcase */
/* eslint-disable-next-line spaced-comment */
/// <reference types="tree-sitter-cli/dsl"/>
//@ts-check


module.exports = grammar({
  name: 'ziggy_schema',

  extras: _ => [/\s/],
  word: $ => $.identifier,

  rules: {
    schema: $ => seq(
      optional($.doc_comment),
      seq("$", '=', field("root", $.expr)),
      repeat(choice($.struct, $.union)),
    ),

    expr: $ => seq(
      repeat(choice('[]', '{:}', '?')),
      choice('bytes', 'int', 'float', 'bool', 'any', $.identifier)
    ),

    identifier: (_) => {
      const identifier_start = /[a-zA-Z_]/;
      const identifier_part = choice(identifier_start, /[0-9]/);
      return token(seq(identifier_start, repeat(identifier_part)));
    },

    struct: $ => seq(
      field("docs", optional($.doc_comment)),
      'struct', field("name", $.identifier), '{',
        commaSep($.struct_field),
        repeat(choice($.struct, $.union)),
      '}',
    ),

    union: $ => seq(
      field("docs", optional($.doc_comment)),
      'union', field("name", $.identifier), '{',
        commaSep($.union_field),
        repeat(choice($.struct, $.union)),
      '}',
    ),

    struct_field: $ => seq(
      field("docs", optional($.doc_comment)),
      field("key", $.identifier), ':', field("value", $.expr),
      field("default", optional(seq('=', $.default)))
    ),
    
    union_field: $ => seq(
      field("docs", optional($.doc_comment)),
      field("key", $.identifier), optional(seq(':', field("value", $.expr))),
      field("default", optional(seq('=', $.default)))
    ),

    doc_comment: _ => repeat1(token(seq('///', /.*/))),

    default: $ => choice(
      "null",
      "true",
      "false",
      "[]",
      "{}",
      $.string,
      $.number,
    ),

    string: (_) => seq('"', /[^"\n]*/, '"'),
    number: (_) => /\d+/,
    enum: $ => seq('@', alias($.identifier, "_enum_name")),
  }
});

/**
 * Creates a rule to optionally match one or more of the rules separated by a comma
 *
 * @param {RuleOrLiteral} rule
 *
 * @return {SeqRule}
 *
 */
function commaSep1(rule) {
  return seq(rule, repeat(seq(",", rule)), optional(","));
}

/**
 * Creates a rule to optionally match one or more of the rules separated by a comma
 *
 * @param {RuleOrLiteral} rule
 *
 * @return {Rule}
 *
 */
function commaSep(rule) {
  return optional(commaSep1(rule));
}
