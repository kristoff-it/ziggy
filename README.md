# Ziggy
A Zig-flavored JSON / YAML / TOML replacement.

## Status
Alpha, using Ziggy now means participating in its development.

## Features

### Tooling Supremacy
Ziggy comes with **ALL** the batteries included!

#### Ziggy CLI
```shell
$ ziggy help

Usage: ziggy COMMAND [OPTIONS]

Commands: 
  fmt          Formats Ziggy files      
  query, q     Queries Ziggy files 
  check        Checks Ziggy files against a Ziggy schema
  convert      Converts JSON, YAML, TOML files from and to Ziggy
  lsp          Starts the Ziggy LSP
  help         Shows this menu and exits

General Options:
 --help, -h    Print command specific usage
```
Development status: 
- [x] fmt 
- [ ] query 
- [ ] check 
- [ ] convert 
- [x] lsp 
- [x] help 

#### Ziggy Tree Sitter Parser
This repository contains a Tree Sitter parser and configuration files for 
various editors.

Development status:
- [x] Helix
- [ ] Vim / Neovim
- [ ] VSCode
- [ ] Sublime

Is your editor not listed / done yet? Feel free to PR it!

#### Handwritten Parsers
Ziggy comes not only with a general purpose Tree Sitter parser that can be used
by any programming language that has C bindings, but it also features two more
handwritten parsers. 

One is another AST parser written in Zig that can be used by applications that 
want something more lean than Tree Sitter.

The other is a type-driven parser that allows parsing a Ziggy file direcly
into a destination Type avoiding any unnecessary allocation.


### Value Types
Ziggy values can be of the following types:

- `struct`
- `map`
- `array`
- `bytes`
- `number`
- `bool` (`true`, `false`)
- `null`


### Structs vs Maps
Visual distinction between key-value container where the keys are expected 
to follow a schema vs when the user should be free do define them dynamically.

Struct: 
```
{
  .name = "Loris Cro",
  .age = 33,
}
```

Map:
```
{
  "foo": "bar",
  "bar": true, 
}
```

Together they help users understand at a glance when they're expected to control
key names and when they're not.

Contrast `package.json` and an hypotetical ziggy version:
```json
{
  "private": true,
  "name": "foo",
  "dependencies": {
    "react": "next",
  },
  "scripts": {
    "setup": "./scripts/setup.sh",
  }
}  
```

```ziggy
{
  .private = true,
  .name = "bun",
  .dependencies = {
    "react": "next",
  },
  .scripts = {
    "setup": "./scripts/setup.sh",
  }
}  
```

### Braceless Top-Level Struct
If the top-level element of your document is a struct, you can omit its curly 
braces and reclaim one level of indentation.

This makes Ziggy a good language for configuration files and markdown frontmatter.


Improved hypotetical `package.ziggy`:

```ziggy
.private = true,
.name = "bun",
.dependencies = {
  "react": "next",
},
.devDependencies = {
  "@types/react": "^18.0.25",
},
.scripts = {
  "setup": "./scripts/setup.sh",
}  
```

Frontmatter example:
```ziggy
---
.title = "My Post #1",
.date = "2024-02-18T10:00:00",
.draft = true,
.tags = ["tag1", "tag2"],
.custom = {
    "bar": true,
    "baz": 123,
},
---
Markdown content.
```
### Tagged String Literals
Ziggy allows you to add a tag to string literals in order to mark them as 
having a special meaning. What those tags are, and what they are supposed to 
mean is up to each different application that consumes Ziggy files.

As a real-life example, check out this Markdown file used by Hugo to generate a 
static site: 
```markdown

---
title: "Tickets"
date: "2020-10-01T00:00:00"
early_bird_end: "2020-11-01T00:00:00"
sales_end: "2020-12-01T00:00:00"
draft: false
---
(...)
```
When trying to access the frontmatter data from a Hugo template, you will find
that `.Data.date` is a Go `Time` instance, but `.Data.early_bird_end` and 
`.Data.sales_end` will be interpreted a strings.

This happens because `date` is part of the Hugo frontmatter schema and so it is
parsed as a `Time` automatically, while in the case of `early_bird_end` and 
`sales_end`, Hugo has no way of knowing that the provided string was intended to
be a date.

The end result is that you will have to parse a date out of those strings in 
your templates (potentially multiple times) and if an error is encountered, 
Hugo will report a template evaluation error as it has no way of knowing if 
the fault lies in the template or the frontmatter file.

This could be fixed by adding a Date type to Ziggy, but it wouldn't solve the 
problem for paths, urls, currencies, semantic version strings, or any other 
special kind of string that an application might care about.

This is how I use tags to solve the problem in [Zine](https://zine-ssg.io), a 
static site generator written by me that uses Ziggy as the frontmatter data 
format:

```ziggy
.title = "Tickets",
.date = @date("2020-10-01T00:00:00"),
.draft = false,
.custom = {
    "early_bird_end": @date("2020-11-01T00:00:00"), 
    "sales_end": @date("2020-12-01T00:00:00"), 
    "some_other_option": true,
},
```

Impovements in the Ziggy version:
- Clear distinction between fixed schema and custom fields.
- Clear tagging of the `date` field as having a required structure.
- Ability to define date fields even when not part of the fixed schema.

### Schema Language
**Note: this part is still vaporware**

Ziggy schemas should help you autogenerate type definitions across different 
programming languages and validate Ziggy files for schema adherence.

```ziggy-schema
struct Project {
    name: bytes,
    version: bytes,
    dependencies: map[Remote | Local],

    struct Remote {
       url: bytes,
       hash: bytes,   
    }

    struct Local {
      path: bytes,
    } 
}
```
Example that adheres to the schema:
```ziggy
.name = "zine",
.version = "0.0.0",
.dependencies = {
    "gfm": Remote {
        .url = "git+https://github.com/kristoff-it/cmark-gfm.git#9b659dada64964c993be6d6ec16b64f1ca1e8f5a",
        .hash = "1220a2d62d1de13c424c79d281c273156083b5232199ff68780c146b9441015ab51c",
    },
    "super": Local {
        .path = "super",
    },
},
.paths = ["."],
```

### Binary Format
**Note: this part is still vaporware**

An optimized binary representation that omits field names and avoids escaping
strings.

### Comments 
Ziggy supports single-line comments using `//`.

### Trailing commas
Ziggy supports trailing commas, which can also be used to interact with the 
formatter in a way similar to `zig fmt`, where a trailing comma means vertical 
alignment, and the absence of one means horizontal alignment.

```ziggy
.horizontal = [1, 2, 3], //no trailing commma
.vertical = [
    1,
    2,
    3,
],
```
