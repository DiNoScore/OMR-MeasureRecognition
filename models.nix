# A derivation that downloads the pre-trained models needed for inference
# At the moment, this downloads only one model, but it can easily be expanded
{
  pkgs ? (import (builtins.fetchTarball {
    name = "nixpkgs-unstable-2021-04-24";
    url = "https://github.com/nixos/nixpkgs/archive/abd57b544e59b54a24f930899329508aa3ec3b17.tar.gz";
    sha256 = "0d6f0d4j5jhnvwdbsgddc62qls7yw1l916mmfq5an9pz5ykc9nwy";
  }) {})
}:

let
  model_type = "R_50_FPN_3x";
  annotation_type = "staves";

  base_github_url = "https://github.com/MarcKletz/OMR-MeasureRecognition/releases/download/0.1";
in
  pkgs.symlinkJoin {
    name = "Models";
    paths = [
      (pkgs.fetchzip {
        name = "${model_type}-${annotation_type}";
        url = "${base_github_url}/${model_type}-${annotation_type}.zip";
        sha256 = "0ga6g4gs50c4i1a7fk1j473d9198h3kdk2p5aqg7dfrlykb7d2wk";
        stripRoot = false;
      })
    ];
  }
