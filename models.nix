# A derivation that downloads the pre-trained models needed for inference
# At the moment, this downloads only one model, but it can easily be expanded
{
  pkgs ? (import (import ./npins).nixpkgs {})
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
