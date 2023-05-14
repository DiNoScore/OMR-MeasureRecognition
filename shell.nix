# This file contains
# detectron2, yacs, iopath, fvcore
# pycocotools
# muscima, mung, omrdatasettools
# pydeck
let
  # The "main" nixpkgs. Pin it
  pkgs = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-2023-05-14";
    url = "https://github.com/nixos/nixpkgs/archive/9241cee3c4cc58d77f588a00f5ef6d69c989fd0d.tar.gz";
    sha256 = "sha256:1vsk8i5p1slfh457iqz20w3wgas5vajin3w5wyjcbr58jmn85lff";
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
