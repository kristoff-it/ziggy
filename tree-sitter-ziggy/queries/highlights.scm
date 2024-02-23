[
  (true)
  (false)
] @constant.builtin.boolean

(null) @constant.builtin

[
  (integer)
  (float)
] @constant.numeric


(struct_field
  key: (_) @keyword)
  
(struct
  name: (_) @type)

(tag) @function

[
  (string) 
  (line_string)*
] @string


(comment) @comment.line

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


(top_comment) @comment.line

