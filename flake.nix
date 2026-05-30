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
          RAYLIB_SO = "${pkgs.raylib}/lib/libraylib.so";
          DYNAMIC_LINKER = "${pkgs.binutils}/nix-support/dynamic-linker";
          shellHook = ''
            export NIX_LDFLAGS="-rpath ${pkgs.raylib}/lib -L${pkgs.raylib}/lib -L${pkgs.libGL}/lib -L${pkgs.xorg.libX11}/lib $NIX_LDFLAGS"
          '';

          # install packages
          packages = (with pkgs; [
            #actual source stuff
            gcc
            fasm
            gnumake

            binutils
            pkg-config

            #raylib stuff
            raylib
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
