/* eslint-disable 80001 */
/* eslint-disable arrow-parens */
/* eslint-disable camelcase */
/* eslint-disable-next-line spaced-comment */
/// <reference types="tree-sitter-cli/dsl"/>
//@ts-check

module.exports = grammar({
  name: 'ziggy',

  extras: $ => [
    /\s/,
    $.comment,
  ],

  supertypes: $ => [
    $.value,
  ],

  word: $ => $.identifier,

  rules: {
    document: $ => seq(
        optional(choice(
          $.top_level_struct,
          $.value,
        )),
      ),

    value: $ => choice(
      $.union,
      $.struct,
      $.dict,
      $.array,
      $.enum,
      $.string,
      $.line_string,
      $.number,
      $.true,
      $.false,
      $.null,
    ),

    top_level_struct: $ => seq(commaSep1($.struct_field)),

    struct: $ => prec(1, seq(
      '.{', 
        commaSep($.struct_field), 
      '}',
    )),
    
    struct_field: $ => seq(
      '.',
      field('key', $.identifier),
      '=',
      field('value', $.value),
    ),

    dict: $ => seq(
      '{', 
        commaSep($.dict_field), 
      '}',
    ),

    dict_field: $ => seq(
      field('key', $.string),
      ':',
      field('value', $.value),
    ),

    array: $ => seq('[', commaSep($.array_elem),']'),

    array_elem: $ => seq(
      $.value,
    ),

    union: $ => seq($.enum, '(', $.value, ')'),
    enum: $ => seq('.', alias($.identifier, "_enum_name")),
 
    line_string: _ => seq("\\\\", /[^\n]*/),
          
    quoted_string: $ => seq(
      '"',
      repeat(choice(
        token.immediate(prec(1, /[^"\\]+/)),
        $.escape_sequence,
      )),
      '"',
    ),

            
    identifier: (_) => {
      const identifier_start = /[a-zA-Z_]/;
      const identifier_part = choice(identifier_start, /[0-9]/);
      return token(seq(identifier_start, repeat(identifier_part)));
    },
    string: $ => choice(
      seq('"', '"'),
      seq('"', $._string_content, '"'),
    ),
    _string_content: $ => repeat1(choice(
      $.string_content,
      $.escape_sequence,
    )),
    string_content: _ => token.immediate(prec(1, /[^\\"\n]+/)),
    escape_sequence: _ => token.immediate(seq(
      '\\',
      /(\"|\\|\/|b|f|n|r|t|u)/,
    )),    

    number: _ => {
      const decimalDigits = /\d+/;
      const signedInteger = seq(optional('-'), decimalDigits);
      const exponentPart = seq(choice('e', 'E'), signedInteger);

      const decimalIntegerLiteral = seq(
        optional('-'),
        choice(
          '0',
          seq(/[1-9]/, optional(decimalDigits)),
        ),
      );

      const decimalLiteral = choice(
        seq(decimalIntegerLiteral, '.', optional(decimalDigits), optional(exponentPart)),
        seq(decimalIntegerLiteral, optional(exponentPart)),
      );

      return token(decimalLiteral);
    },
    
    true: _ => 'true',
    false: _ => 'false',
    null: _ => 'null',

    // comment: _ => token(seq('//', token.immediate(/[^!]/), /.*/)),    
    comment: _ => token(seq('//', /.*/, '\n')),    
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
