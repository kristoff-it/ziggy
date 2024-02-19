/* eslint-disable 80001 */
/* eslint-disable arrow-parens */
/* eslint-disable camelcase */
/* eslint-disable-next-line spaced-comment */
/// <reference types="tree-sitter-cli/dsl"/>
//@ts-check

module.exports = grammar({
  name: 'ziggy',

  extras: $ => [/\s/],

  rules: {
    document: $ => optional(choice(
      $.top_level_struct,
      $._value,
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

    top_level_struct: $ => seq(commaSep1($.struct_field), optional($.comment)),

    struct: $ => prec(1, seq(
      field('name', optional($.struct_name)), 
      '{', 
        commaSep($.struct_field), 
        optional($.comment),
      '}',
    )),
    
    struct_name: $ => seq(/[A-Z]/, repeat(/[a-zA-Z0-9_]/)),
    
    struct_field: $ => seq(
      optional($.comment),
      '.',
      field('key', $.identifier),
      '=',
      field('value', $._value),
    ),

    map: $ => seq(
      '{', 
        commaSep($.map_field), 
        optional($.comment),
      '}',
    ),

    map_field: $ => seq(
      optional($.comment),
      field('key', $.string),
      ':',
      field('value', $._value),
    ),

    array: $ => seq('[', commaSep($.array_elem), optional($.comment),']'),

    array_elem: $ => seq(
      optional($.comment),
      $._value,
    ),

    tag_string: $ => seq('@', field('name', $.tag), '(', $.string, ')'),

    tag: _ => seq(/[a-z]/, repeat(/[a-z_0-9]/)),

 
    string: $ => choice(
      $.quoted_string,
      repeat1($.line_string),
    ),
    
    line_string: $ => seq("\\\\", /[^\n]*/),
          
    quoted_string: $ => seq(
      '"',
      repeat(choice(
        token.immediate(prec(1, /[^"\\]+/)),
        $.escape_sequence,
      )),
      '"',
    ),

            
    escape_sequence: _ => seq(
      "\\",
      choice(/x[0-9a-fA-f]{2}/, /u\{[0-9a-fA-F]+\}/, /[nr\\t'"]/)
    ),

    identifier: (_) => {
      const identifier_start = /[a-zA-Z_]/;
      const identifier_part = choice(identifier_start, /[0-9]/);
      return token(seq(identifier_start, repeat(identifier_part)));
    },

    
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

    comment: _ => repeat1(token(seq('//', /.*/))),    
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
