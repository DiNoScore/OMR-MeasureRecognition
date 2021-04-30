# This file contains
# detectron2, yacs, iopath, fvcore
# pycocotools
# muscima, mung, omrdatasettools
# pydeck
let
  # The "main" nixpkgs. Pin it
  pkgs = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-2021-04-24";
    url = "https://github.com/nixos/nixpkgs/archive/abd57b544e59b54a24f930899329508aa3ec3b17.tar.gz";
    sha256 = "0d6f0d4j5jhnvwdbsgddc62qls7yw1l916mmfq5an9pz5ykc9nwy";
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
