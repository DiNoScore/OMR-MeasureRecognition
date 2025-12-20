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
    scikit-learn
    detectron2
    torch
    torchvision
    opencv4
    omrdatasettools
    flask
    gunicorn
    (pkgs.python3Packages.callPackage ./server_app.nix {})
  ];
  python-with-my-packages = (pkgs.python3.withPackages my-python-packages).override (args: { ignoreCollisions = true; });
in
pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs; [
    python-with-my-packages
    ninja
  ];
}
