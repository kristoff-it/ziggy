{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
        url = "github:hercules-ci/flake-parts";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
      {
        packages.default = pkgs.stdenv.mkDerivation {
            name = "ziggy";
            version = "0.0.0";
            src = ./.;
            nativeBuildInputs = [ pkgs.zig.hook ];
        };
      };
    };
}
