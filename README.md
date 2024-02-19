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
  fmt          Format Ziggy files      
  query, q     Query Ziggy files 
  check        Check Ziggy files against a Ziggy schema 
  convert      Convert between JSON, YAML, TOML files and Ziggy
  lsp          Start the Ziggy LSP
  help         Show this menu and exit

General Options:
  --help, -h   Print command specific usage
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
- `string`
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

#### Frontmatter example
With outer curlies
```ziggy
---
{
    .title = "My Post #1",
    .date = "2024-02-18T10:00:00",
    .draft = true,
    .tags = ["tag1", "tag2"],
    .custom = {
        "bar": true,
        "baz": 123,
    },
}
---
Markdown content.
```

Without: 
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
### Tagged Unions Of Structs
JSON and similar formats don't help you design your data types in a user-frieldy
manner. 

In this context user-friendly means making it easier for the user to match the 
data to a type in their language. For example tagged unions are famously annoying
to parse from JSON because there is no standardized way to express a tagged union.

As an example, look at this JSON:
```json
{
  "dependencies": {
    "foo": {
      "url": "(...)",
      "hash": "(...)"
    },
    "bar": {
      "path": "foo/bar/baz" 
    }
  }
}
```
In this example dependencies can either be local (`path` field) or remote 
(`url` and `hash`). 

Unfortunately this layout makes it hard for users to define a tagged union of
(`Remote`, `Local`) types and have a type-driven parser automatically figure 
out the parsing code, as that would rely on shape-matching (ie selecting
candidate output types based on presence/absence of fields in the JSON object).


People who are aware of these problems will do the following:
```json
{
  "dependencies": {
    "foo": {
      "remote": {
        "url": "(...)",
        "hash": "(...)"
      }
    },
    "bar": {
      "local": {
        "path": "foo/bar/baz" 
      }
    }
  }
}
```
This works but steals one indentation level and it doesn't make it immediately
clear that what you're looking at is a union of two different structs (ie key-value 
data structure where the application controls key names).

Ziggy allows you to specify struct names which can help both producers and consumers
come to an understanding about the shape of the data without sacrificing indentation.

Here's the same example as above, but in Ziggy:
```ziggy
.dependencies = {
    "foo": Remote {
        .url = "(...)",
        .hash = "(...)",  
    },
    "bar": Local {
        .path = "foo/bar/baz",
    }
},
```

A Ziggy parser will be able to use struct names to select the correct type to 
use for deserialization without the need to rely on shape-matching.

This is not a silver-bullet by itself, though. 

Users are not *required* to use struct names, so somebody could still write a Ziggy
file with a hard-to-recognize union, but the hope is by making it a first-class
feature of the language people will be steered naturally towards creating better 
data types.

To enforce the presence of struct names when it matters, see below the section
about Ziggy Schemas.

#### Multiline String Literals
Ziggy supports multiline string literals using the same notation used by Zig.

```ziggy
.title = "Lorem Ipsum",
.description = 
    \\Lorem Ipsum has been the industry's standard 
    \\dummy text ever since the 1500s, when an 
    \\unknown printer took a galley of type and 
    \\scrambled it to make a type specimen book. 
,
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

Improvements in the Ziggy version:
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

Comments can be placed directly inside structs and arrays.

This allows you to document individual fields / array values as well as toggle
them off by commenting them out

Example:
```ziggy
.name = "zine",

// version must be a semver string
.version = "0.0.0",
.dependencies = {
    // here I've commented out .url and .hash temporarily to work on a local
    // checkout of the dependency
    "gfm": Remote {
        // .url = "git+https://github.com/kristoff-it/cmark-gfm.git#9b659dada64964c993be6d6ec16b64f1ca1e8f5a",
        // .hash = "1220a2d62d1de13c424c79d281c273156083b5232199ff68780c146b9441015ab51c",
        .path = "../gfm",
    },
    
    // "super": Local {
    //     .path = "super",
    // },
},
.paths = [
    ".",
],
```


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
