/* eslint-disable 80001 */
/* eslint-disable arrow-parens */
/* eslint-disable camelcase */
/* eslint-disable-next-line spaced-comment */
/// <reference types="tree-sitter-cli/dsl"/>
//@ts-check


module.exports = grammar({
  name: 'ziggy_schema',

  extras: $ => [/\s/],
  word: $ => $.identifier,

  rules: {
    schema: $ => seq(
      seq("root", '=', field("root", $.expr)),
      field("tags", commaSep($.tag)),
      field("structs", repeat($.struct))
    ),

    
    tag_name: $ => seq('@', alias($.identifier, "_tag_name")),
    enum_definition: $ => seq("enum", "{", commaSep1($.identifier), "}"),
    tag: $ => seq(
      field("docs", optional($.doc_comment)), 
      field("name", $.tag_name),
      "=",
      field("expr", choice("bytes", $.enum_definition)),
    ),
    
    expr: $ => choice(
      $.struct_union,
      $.identifier,
      $.tag_name,
      $.map,
      $.array,
      $.optional,
      "bytes",
      "int",
      "float",
      "bool",
      "any",
      "unknown",
    ),

    struct_union: $ => seq($.identifier, repeat1(seq('|', $.identifier))),


    
    identifier: (_) => {
      const identifier_start = /[a-zA-Z_]/;
      const identifier_part = choice(identifier_start, /[0-9]/);
      return token(seq(identifier_start, repeat(identifier_part)));
    },

    map: $ => seq("map", '[', $.expr, ']'), 
    array: $ => seq('[', $.expr, ']'), 
    optional: $ => seq('?', $.expr),

    struct: $ => seq(
      field("docs", optional($.doc_comment)),
      'struct', field("name", $.identifier), '{',
        commaSep($.struct_field),
      '}',
    ),

    struct_field: $ => seq(
      field("docs", optional($.doc_comment)),
      field("key", $.identifier), ':', field("value", $.expr)
    ),
    
    doc_comment: _ => repeat1(token(seq('///', /.*/))),    
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
