{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, lib, ... }:
        let
          buildInputs = lib.optionals pkgs.stdenv.isLinux [
            pkgs.alsa-lib
            pkgs.libpulseaudio
            pkgs.pipewire
          ];

          iai-sound-effects = pkgs.stdenv.mkDerivation {
            name = "iai-sound-effects";
            src = lib.cleanSource ./.;
            doCheck = true;

            inherit buildInputs;
            nativeBuildInputs = [
              pkgs.zig_0_15.hook
              pkgs.pkg-config
            ];

            postConfigure = ''
              ln -s ${pkgs.callPackage ./.deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p

              # Remove NIX_CFLAGS_COMPILE because zig cannot understand it
              unset NIX_CFLAGS_COMPILE
            '';
          };
        in
        {
          treefmt = {
            projectRootFile = ".git/config";

            # Nix
            programs.nixfmt.enable = true;

            # Zig
            programs.zig.enable = true;
            settings.formatter.zig.command = lib.getExe pkgs.zig_0_15;

            # GitHub Actions
            programs.actionlint.enable = true;

            # Markdown
            programs.mdformat.enable = true;

            # ShellScript
            programs.shellcheck.enable = true;
            programs.shfmt.enable = true;
          };

          packages = {
            inherit iai-sound-effects;
            default = iai-sound-effects;
          };

          checks = {
            inherit iai-sound-effects;
          };

          devShells.default = pkgs.mkShell {
            inherit buildInputs;
            nativeBuildInputs = [
              pkgs.zig_0_15 # Zig compiler
              pkgs.pkg-config # pkg-config

              pkgs.nil # Nix LSP
              pkgs.zls_0_15 # Zig LSP

              # Music Player
              pkgs.sox # Use this command as: `play result.wav`

              pkgs.zon2nix # zon2nix
            ];

            shellHook = ''
              # Remove NIX_CFLAGS_COMPILE because zig cannot understand it
              unset NIX_CFLAGS_COMPILE
            '';
          };
        };
    };
}
