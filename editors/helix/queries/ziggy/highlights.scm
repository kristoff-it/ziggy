[
  (true)
  (false)
] @constant.builtin.boolean

(null) @constant.builtin

(number) @constant.numeric

(struct_field
  key: (_) @keyword)
  
(struct
  name: (_) @keyword)

(tag) @function

(comment) @comment.line

(string) @string

(escape_sequence) @constant.character.escape

(ERROR) @error

"," @punctuation.delimiter

[
  "["
  "]"
  "{"
  "}"
  "("
  ")"
] @punctuation.bracket
