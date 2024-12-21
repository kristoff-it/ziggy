# Ziggy
A data serialization language for expressing clear API messages, config files, etc.

## Status
Alpha, using Ziggy now means participating in its development.

## At a glance

```zig
.id = @uuid("..."),
.time = 1710085168,
.payload = Command {
  .do = @action("clear_chat"),
  .sender = "kristoff-it",
  .roles = ["admin", "mod"],
  .extra = {
    "agent": "Mozilla/5.0",
    "os": "Linux/x64", 
  },
}
```
## Value Types
Ziggy values can be of the following types:

- Bytes `"🧑‍🚀"`, `"\x1B[?1000h gang"`, `\\multiline`
- Numbers `123_000`, `1.23`, `0xff_ff_ff`, `0o7_5_5`, `0b01_01_01` 
- Null `null`
- Bool `true`, `false`
- Custom Literals `@date("2020-12-01")`, `@v("1.0.0")`, `@foo("bar")`
- Array `[1, 2, 3]`
- Struct `{ .fixed = "schema" }`, `Named { .for = "unions of structs" }`
- Map `{ "custom": "keys" }`


## Documentation

See the official website: https://ziggy-lang.io

## Development

In order to build with nix using the correct dependencies please keep
updated the [deps.nix](./deps.nix) file every time the [build.zig.zon](build.zig.zon)
is changed. In order to do so use

```bash
nix run .#update-deps
```
