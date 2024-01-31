# This file contains
let
  npins = import ./npins;
  pkgs = import npins.nixpkgs {};

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
    opencv4
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
  ];
}
