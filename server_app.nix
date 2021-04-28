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
, opencv3
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
    opencv3
  ];

  unpackPhase = ''
    cp -r $src/* .
  '';
  
  doCheck = false;
  # pythonImportsCheck = [ "inference_cli" "inference_server" ];
}
