# Adding Ziggy

In your Helix runtime directory (https://docs.helix-editor.com/install.html#configuring-helixs-runtime-files), create `languages.toml` if not existent and copy in the relevant section from the `languages.toml` file present in this directory.

After that, copy from this repo `queries/ziggy` into the corresponding location in the Helix runtime directory.

# Adding ZMD

`.zmd` files are Markdown files that use Ziggy as the frontmatter language.

To enable support for ZMD files, copy the relevant section from `languages.toml` and the `queries/ziggy-markdown` directory just like you did for Ziggy.
