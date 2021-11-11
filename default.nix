let
    pkgs = import pkgsPath {};
    pkgsPath = builtins.fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/26f5e6dd5f2d703d5c39d661540397ea119aa94f.tar.gz";
        sha256 = "1wd594najdva5gzckdb5hl4qxxcjjydcyd1lz26dy29ayqszwh6z";
    };
    inherit (pkgs) lib;
    buildPkgs = import pkgsPath {};
    nixos = buildPkgs.nixos {
        imports = [
            (pkgsPath + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix")
            ./hardware-configuration.nix
        ];
        nix.nixPath = [
            "nixpkgs=${pkgsPath}"
        ];
    };
in {
  iso = nixos.config.system.build.isoImage;
  inherit (nixos) config pkgs;
  inherit pkgsPath;
}
