{
  description = "pong_asm";

  inputs = {
    # nixpkgs unstable for latest versions
    pkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs: 
    (flake-utils.lib.eachDefaultSystem (system:
      let
        repo_root = builtins.toString ./.;
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        # Nix shell
        devShells.default = pkgs.mkShell {
          # install packages
          packages = (with pkgs; [
            #actual source stuff
            nasm
            gnumake

            #raylib stuff
            mesa
            glibc
            libXi
            libXcursor
            libXrandr
            libglvnd
            libXinerama
            wayland
            libxkbcommon
          ]);
        };
      })
    );
}
