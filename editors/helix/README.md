# Ziggy support for Helix

1. In your Helix **runtime directory** (https://docs.helix-editor.com/install.html#configuring-helixs-runtime-files), copy the Tree Sitter queries from our parsers.
  From the root of this repository, run the following two commands after replacing `HELIX_RUNTIME_PATH`:
  - `cp -rT tree-sitter-ziggy/queries HELIX_RUNTIME_PATH/queries/ziggy`
  - `cp -rT tree-sitter-ziggy-schema/queries HELIX_RUNTIME_PATH/queries/ziggy_schema`

NOTE: '-T' makes it so you can run the command multiple times without nesting new copies of `queries` more deeply than intended. Also macOS doesn't support it.


2. In your Helix **config directory** (usually `~/.config/helix/`create `languages.toml` and copy in the relevant sections from the `languages.toml` file present in this directory.

3. Run `hx --grammar build`


