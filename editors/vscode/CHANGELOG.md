# Change Log

All notable changes to the Ziggy extension will be documented in this file.

Documentation: https://ziggy-lang.io

## [v0.1.2]
Fix mistake when creating the vscode extension bundle.

## [v0.1.0]
- Ziggy Schemas now allow to specify omittable fields (see new docs page)
- Zig types can now be tested for compatibility against Ziggy Schemas
- (De)Serializer now accepts a new type for ziggy_options with extended functionality.
- The Language Server now supports a mostly complete but rudimentary implementation of autocompletion/hover/goto definition. It’s not yet at the level of SuperHTML but it’s just a matter of polishing the existing implementation.
- Plus a big list of bugfixes and minor improvements.

## [v0.0.1]

Syntax for both Ziggy Documents and Ziggy Schemas has changed, see https://ziggy-lang.io/log/ for more info.

This release introduces a WASM WASI build of the language server bundled with the extension, meaning that you
don't need the Ziggy CLI tool available in PATH for this extension to work correctly.

The Ziggy language server will also work with SuperMD files, providing code intelligence for the Ziggy
frontmatter embedded within. Support for SuperMD files will be removed in the future once SuperMD has its own
dedicated language server.



