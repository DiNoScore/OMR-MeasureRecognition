# This file contains
# detectron2, yacs, iopath, fvcore
# pycocotools
# muscima, mung, omrdatasettools
# pydeck
let
  pkgs = import ./custom-dependencies.nix;

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
