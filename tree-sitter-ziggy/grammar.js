
/* eslint-disable 80001 */
/* eslint-disable arrow-parens */
/* eslint-disable camelcase */
/* eslint-disable-next-line spaced-comment */
/// <reference types="tree-sitter-cli/dsl"/>
//@ts-check

module.exports = grammar({
  name: 'ziggy',

  extras: _ => [
    /\s/,
  ],

  rules: {
    // TODO: add the actual grammar rules
    document: $ => optional(choice(
      $.top_level_struct,
      $.struct,
      $.map,
      $.array,
      $.string,
      $.number,
      $.true,
      $.false,
      $.null,
    )),

    _value: $ => choice(
      $.struct,
      $.map,
      $.array,
      $.tag_string,
      $.string,
      $.number,
      $.true,
      $.false,
      $.null,
    ),

    top_level_struct: $ => commaSep1($.struct_field),

    struct: $ => prec(1, seq(
      '{', commaSep($.struct_field), '}',
    )),

    map: $ => seq(
      '{', commaSep($.map_field), '}',
    ),

    array: $ => seq('[', commaSep($._value), ']'),

    struct_field: $ => seq(
      field('key', $.identifier),
      '=',
      field('value', $._value),
    ),

    identifier: (_) => {
      const identifier_start = /[a-zA-Z_]/;
      const identifier_part = choice(identifier_start, /[0-9]/);
      return token(seq(".", identifier_start, repeat(identifier_part)));
    },


    map_field: $ => seq(
      field('key', $.string),
      ':',
      field('value', $._value),
    ),

    tag_string: $ => seq('@', $.tag, '(', $.string, ')'),

    tag: _ => repeat1(/[a-zA-Z_]/),

    string: $ => choice(
      seq('"', '"'),
      seq('"', $.string_content, '"'),
    ),

    string_content: $ => repeat1(choice(
      token.immediate(prec(1, /[^\\"\n]+/)),
      $.escape_sequence,
    )),

    escape_sequence: _ => token.immediate(seq(
      '\\',
      /(\"|\\|\/|b|f|n|r|t|u)/,
    )),

    number: _ => {
      const decimal_digits = /\d+/;
      const signed_integer = seq(optional('-'), decimal_digits);
      const exponent_part = seq(choice('e', 'E'), signed_integer);

      const decimal_integer_literal = seq(
        optional('-'),
        choice(
          '0',
          seq(/[1-9]/, optional(decimal_digits)),
        ),
      );

      const decimal_literal = choice(
        seq(decimal_integer_literal, '.', optional(decimal_digits), optional(exponent_part)),
        seq(decimal_integer_literal, optional(exponent_part)),
      );

      return token(decimal_literal);
    },

    true: _ => 'true',

    false: _ => 'false',

    null: _ => 'null',
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
