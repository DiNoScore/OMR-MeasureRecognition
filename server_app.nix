# Nix package for Python/inference_server.py. Only used by the NixOS module in server.nix,
# otherwise you can simply call the commands from the README.
{ lib
, buildPythonPackage
, writeText
, linkFarm
, flask
, pillow
, pytorch
, detectron2
, torchvision
, opencv4
}:

buildPythonPackage rec {
  pname = "inference-server";
  version = "42";

  src = ./Python;
  
  propagatedBuildInputs = [
    flask
    pillow
    pytorch
    detectron2
    torchvision
    opencv4
  ];

  unpackPhase = ''
    cp -r $src/* .
  '';
  
  doCheck = false;
  pythonImportsCheck = [
    "inference_cli"
    # "inference_server" # This is broken because it will load too much on import due to the `before_first_request` removal
    "flask"
  ];
}
