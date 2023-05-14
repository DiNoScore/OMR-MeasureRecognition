# An overlay that will give you the custom dependenceis needed to run the thing
# Some pinned nixpkgs with custom dependencies. Import this and get some "pkgs" attribute.
let
  # Some nixpkgs with open pull requests
  # https://github.com/NixOS/nixpkgs/pull/120472
  pkgsOMR = builtins.fetchTarball {
    name = "nixpkgs-omr-2022-05-14";
    url = "https://github.com/piegamesde/nixpkgs/archive/762731e0e01a0b94d2f14059d35418cf3e2da202.tar.gz";
    sha256 = "sha256:1hiqb1bhmfbbi7hdx058zmaw2sbi5fpv4dysi93fpzhliw71609l";
  };
  # https://github.com/NixOS/nixpkgs/pull/120517
  pkgsDetectron = builtins.fetchTarball {
    name = "nixpkgs-detectron-2023-05-14";
    url = "https://github.com/piegamesde/nixpkgs/archive/aae2ed6cb9fd9bbe12605f793dbba2c015ba689b.tar.gz";
    sha256 = "sha256:04vp220znj6r6qwqn8mrlj019k2hs1p0n86k5zaxr2wbj5psysy5";
  };
in
  (pkgs: super: let inherit (pkgs) writeText; in {
    python3 = super.python3.override {
      # Careful, we're using a different self and super here!
      packageOverrides = pkgs: super: {
        iopath = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/iopath/default.nix" { };
        yacs = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/yacs/default.nix" { };
        fvcore = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/fvcore/default.nix" { };
        omegaconf = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/omegaconf/default.nix" { };
        detectron2 = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/detectron2/default.nix" { };

        mung = (pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/mung/default.nix" { }).overrideAttrs (old: {
          postInstall = "rm -rf $out/bin";
        });
        muscima = pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/muscima/default.nix" { };
        omrdatasettools = (pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/omrdatasettools/default.nix" { }).overrideAttrs (old: {
          postInstall = "rm -rf $out/bin";
        });
      };
    };
    python3Packages = super.recurseIntoAttrs (pkgs.python3.pkgs);
  })
