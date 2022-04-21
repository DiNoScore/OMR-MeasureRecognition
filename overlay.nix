# An overlay that will give you the custom dependenceis needed to run the thing
# Some pinned nixpkgs with custom dependencies. Import this and get some "pkgs" attribute.
let
  # Some nixpkgs with open pull requests
  # https://github.com/NixOS/nixpkgs/pull/120472
  pkgsOMR = builtins.fetchTarball {
    name = "nixpkgs-omr-2022-04-21";
    url = "https://github.com/piegamesde/nixpkgs/archive/68ec1b5f826a13911d8e5c2a0f758c20f8011805.tar.gz";
    sha256 = "1m0ijw4lrlysxrdb64pz67mfq0bargq4cfbdy5bins2kz6b2vhgd";
  };
  # https://github.com/NixOS/nixpkgs/pull/120517
  pkgsDetectron = builtins.fetchTarball {
    name = "nixpkgs-detectron-2022-04-21";
    url = "https://github.com/piegamesde/nixpkgs/archive/a4ca96a054b678f1e5a0156af9ddf92414c237f3.tar.gz";
    sha256 = "1x3si1047901i59an5hgxwyknjl5f6aw9d71dwsk7fqrlaypzvnd";
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
        hydra-core = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/hydra-core/default.nix" { };
        detectron2 = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/detectron2/default.nix" { };

        mung = (pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/mung/default.nix" { }).overrideAttrs (old: {
          postInstall = "rm -rf $out/bin";
        });
        muscima = pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/muscima/default.nix" { };
        omrdatasettools = (pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/omrdatasettools/default.nix" { }).overrideAttrs (old: {
          postInstall = "rm -rf $out/bin";
        });

        # TODO remove with next update
        pydeck = (pkgs.buildPythonPackage rec {
          pname = "pydeck";
          version = "0.7.1";

          src = pkgs.fetchPypi {
            inherit pname version;
            sha256 = "0bmx5q1mpdp2rx89qp1bd8b6s8a5l6zn5jyp4xny243mkz4h2xlh";
          };

          patches = [(writeText "fixup-fuckup.patch" ''
            diff --git a/pyproject.toml b/pyproject.toml
            index 8b9ec0e87d..32cbac6ef9 100644
            --- a/pyproject.toml
            +++ b/pyproject.toml
            @@ -1,5 +1,7 @@
             [project]
             name = "pydeck"
            -version = "0.3.0"
            +version = "0.7.1"
            +requires-python = ">=3.7"

            +[build-system]
             requires = [
          '')];

          checkInputs = with pkgs; [
            jupyter
            pandas
            pytestCheckHook
          ];

          disabledTests = [
            "test_nbconvert" # Does internet
          ];

          propagatedBuildInputs = with pkgs; [
            ipykernel
            ipywidgets
            traitlets
            jinja2
            numpy
          ];
        });
      };
    };
    python3Packages = super.recurseIntoAttrs (pkgs.python3.pkgs);
  })
