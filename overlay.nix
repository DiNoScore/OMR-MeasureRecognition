# An overlay that will give you the custom dependenceis needed to run the thing
# Some pinned nixpkgs with custom dependencies. Import this and get some "pkgs" attribute.
let
  # Some nixpkgs with open pull requests
  pkgsOMR = builtins.fetchTarball {
    name = "nixpkgs-omr-2021-04-24";
    url = "https://github.com/piegamesde/nixpkgs/archive/7e5f1ffcb8a777c86d209dcda7ddd67a7b5a9745.tar.gz";
    sha256 = "1ipr5hjlvazrq9ycxc0ggm8hpgzpmp6vv6pghankszsmv6n28w55";
  };

  pkgsDetectron = builtins.fetchTarball {
    name = "nixpkgs-detectron-2021-08-19";
    url = "https://github.com/piegamesde/nixpkgs/archive/eb391cd57bece806cabc3e6280ef9d52944fc61e.tar.gz";
    sha256 = "1v21anyhy3f8gzmhnj1facz8lpy2qwccw4p8k97ch7whcw1xxn11";
  };
in
  (pkgs: super: {
    python38 = super.python38.override {
      # Careful, we're using a different self and super here!
      packageOverrides = pkgs: super: {
        iopath = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/iopath/default.nix" { };
        yacs = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/yacs/default.nix" { };
        fvcore = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/fvcore/default.nix" { };
        omegaconf = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/omegaconf/default.nix" { };
        hydra-core = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/hydra-core/default.nix" { };
        detectron2 = pkgs.callPackage "${pkgsDetectron}/pkgs/development/python-modules/detectron2/default.nix" { };

        # streamlit requires click < 8 for now
        click = pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/click/default.nix" { };

        mung = pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/mung/default.nix" { };
        muscima = pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/muscima/default.nix" { };
        omrdatasettools = pkgs.callPackage "${pkgsOMR}/pkgs/development/python-modules/omrdatasettools/default.nix" { };
        
        pydeck = (pkgs.buildPythonPackage rec {
          pname = "pydeck";
          version = "0.6.1";

          src = pkgs.fetchPypi {
            inherit pname version;
            sha256 = "1l18iy3l6cgqlxwf9bvqijy494hx4hsnj1nm9i2pabz94i24hcd4";
          };

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
    python38Packages = super.recurseIntoAttrs (pkgs.python38.pkgs);

    streamlit = (super.streamlit.overridePythonAttrs (old: rec {
      version = "0.86.0";

      src = pkgs.python38Packages.fetchPypi {
        inherit version;
        inherit (old) pname format;
        sha256 = "1nwa647cj1gwvpik84cfbdsis2aqh7hbzwnh0r5i5bf7ncv8qab6";
      };
      propagatedBuildInputs = (pkgs.lib.remove pkgs.python38Packages.tornado_5 old.propagatedBuildInputs) ++ (with pkgs.python38Packages; [
        altair
        astor
        base58
        blinker
        cachetools
        click
        pandas
        pip
        protobuf
        pyarrow
        pydeck
        GitPython
        tornado
        tzlocal
        validators
        watchdog
      ]);
    }));
  })
