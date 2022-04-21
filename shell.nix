# This file contains
# detectron2, yacs, iopath, fvcore
# pycocotools
# muscima, mung, omrdatasettools
# pydeck
let
  # The "main" nixpkgs. Pin it
  pkgs = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-2022-04-21";
    url = "https://github.com/nixos/nixpkgs/archive/4c344da29a5b46caadb87df1d194082a190e1199.tar.gz";
    sha256 = "1m2m3wi52pr6gw5vg35zf3ykvp4ksllig5gdw6zvhk7i6v78ryci";
  }) {
    overlays = [
      (import ./overlay.nix)
    ];
  };

  my-python-packages = python-packages: with python-packages; [
    pip
    virtualenv
    pandas
    tqdm
    pillow
    requests
    scikitlearn
    detectron2
    pytorch
    torchvision
    opencv3
    omrdatasettools
    flask
    gunicorn
  ];
  # TODO remove the override
  python-with-my-packages = (pkgs.python3.withPackages my-python-packages).override (args: { ignoreCollisions = true; });
in
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs; [
      python-with-my-packages
      ninja
      opencv2
      streamlit
    ];
  }
