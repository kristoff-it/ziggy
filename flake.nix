{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { pkgs, lib, config, ... }: {
        packages = {
          ziggy = pkgs.stdenv.mkDerivation {
            name = "ziggy";
            version = "0.0.0";
            src = ./.;
            postPatch = ''
              ln -s ${pkgs.callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
            '';
            nativeBuildInputs = [ pkgs.zig.hook ];
          };
          default = config.packages.ziggy;
          update-deps = pkgs.writeShellApplication {
            name = "update-deps";
            text = "${lib.getExe pkgs.zon2nix} > deps.nix";
          };
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [ config.packages.default.nativeBuildInputs ];
        };
      };
    };
}
