# This file contains
# detectron2, yacs, iopath, fvcore
# pycocotools
# muscima, mung, omrdatasettools
# pydeck
let
  # The "main" nixpkgs. Pin it
  pkgs = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-2021-08-19";
    url = "https://github.com/nixos/nixpkgs/archive/253aecf69ed7595aaefabde779aa6449195bebb7.tar.gz";
    sha256 = "14szn1k345jfm47k6vcgbxprmw1v16n7mvyhcdl7jbjmcggjh4z7";
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
  python-with-my-packages = pkgs.python38.withPackages my-python-packages;
in
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    buildInputs = with pkgs; [
      python-with-my-packages
      ninja
      opencv2
      streamlit
    ];
  }
