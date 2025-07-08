
(struct_field
  key: (_) @keyword)
  
(tag_name) @function

[
  "unknown"
  "any"
  "struct"
  "root"
  "enum"
  "null"
] @keyword

(string) @string
(number) @number

[
  "true"
  "false"
] @bool

(identifier) @type

"?" @type

[
  "bool"
  "bytes"
  "int"
  "float"
] @constant.builtin


(doc_comment) @comment.line.documentation

(ERROR) @error

"," @punctuation.delimiter

["|" ":"] @punctuation


[
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket
