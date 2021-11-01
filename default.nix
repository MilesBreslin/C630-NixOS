let
    pkgs = import <nixpkgs> {};
    inherit (pkgs) lib;
    buildPkgs = import <nixpkgs> (lib.optionalAttrs (builtins.currentSystem != "aarch64-linux") {
        crossSystem = {
            config = "aarch64-unknown-linux-gnu";
        };
    });
    nixos = buildPkgs.nixos {
        imports = [
            <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
            ./hardware-configuration.nix
        ];
        nix.nixPath = [
            "nixpkgs=${if lib.isStorePath <nixpkgs> then
                <nixpkgs> else pkgs.copyPathToStore <nixpkgs>
            }"
        ];
    };
in {
  iso = nixos.config.system.build.isoImage;
  inherit (nixos) config;
}
