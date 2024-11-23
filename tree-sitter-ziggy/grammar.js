/* eslint-disable 80001 */
/* eslint-disable arrow-parens */
/* eslint-disable camelcase */
/* eslint-disable-next-line spaced-comment */
/// <reference types="tree-sitter-cli/dsl"/>
//@ts-check

const
  bin = /[01]/,
  bin_ = seq(optional("_"), bin),
  oct = /[0-7]/,
  oct_ = seq(optional("_"), oct),
  hex = /[0-9a-fA-F]/,
  hex_ = seq(optional("_"), hex),
  dec = /[0-9]/,
  dec_ = seq(optional("_"), dec),
  bin_int = seq(bin, repeat(bin_)),
  oct_int = seq(oct, repeat(oct_)),
  dec_int = seq(dec, repeat(dec_)),
  hex_int = seq(hex, repeat(hex_))

module.exports = grammar({
  name: 'ziggy',

  extras: $ => [/\s/],

  rules: {
    document: $ => seq(
        optional($.top_comment),
        optional(choice(
          $.top_level_struct,
          $._value,
        )),
      ),

    _value: $ => choice(
      $.struct,
      $.map,
      $.array,
      $.tag_string,
      $.string,
      $.float,
      $.integer,
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

    tag_string: $ => seq('@', field('name', $.tag), '(', $.quoted_string, ')'),

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

    float: (_) => choice(
        token(
            seq(/[-]?/,"0x", hex_int, ".", hex_int, optional(seq(/[pP][-+]?/, dec_int)))
        ),
        token(seq(/[-]?/,dec_int, ".", dec_int, optional(seq(/[eE][-+]?/, dec_int)))),
        token(seq(/[-]?/,"0x", hex_int, /[pP][-+]?/, dec_int)),
        token(seq(/[-]?/,dec_int, /[eE][-+]?/, dec_int))
    ),

    integer: (_) => choice(
        token(seq(/[-]?/,"0b", bin_int)),
        token(seq(/[-]?/,"0o", oct_int)),
        token(seq(/[-]?/,"0x", hex_int)),
        token(seq(/[-]?/,dec_int))
    ),
    

    true: _ => 'true',

    false: _ => 'false',

    null: _ => 'null',

    comment: _ => repeat1(token(seq('//', token.immediate(/[^!]/), /.*/))),    
    top_comment: $ => repeat1(token(seq('//!', /.*/))),    
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
