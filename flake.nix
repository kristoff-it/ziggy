{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig2nix = {
      url = "github:Cloudef/zig2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    {
      self,
      nixpkgs,
      zig2nix,

      ...
    }:
    let
      inherit (nixpkgs) lib;
      forAllSystems =
        body:
        lib.genAttrs lib.systems.flakeExposed (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            zig016 = zig2nix.packages.${system}.zig-master;
            env = zig2nix.outputs.zig-env.${system} {
              inherit nixpkgs;
              zig = zig016;
            };
          in
          body {
            inherit system pkgs zig016 env;
          }
        );
    in
    {
      packages = forAllSystems (
        {
          system,
          env,
          zig016,
          ...
        }:
        {
          ziggy = env.package {
            src = lib.cleanSource ./.;
            nativeBuildInputs = [ zig016 ];
            buildInputs = [ zig016 ];
            zigPreferMusl = false;
          };
          default = self.packages.${system}.ziggy;
        }
      );
      devShells = forAllSystems (
        { env, zig016, ... }:
        {
          default = env.mkShell { packages = [ zig016 ]; };
        }
      );
    };
}
