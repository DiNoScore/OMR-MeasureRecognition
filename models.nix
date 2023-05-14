# A derivation that downloads the pre-trained models needed for inference
# At the moment, this downloads only one model, but it can easily be expanded
{
  pkgs ? (import (builtins.fetchTarball {
    name = "nixpkgs-unstable-2023-05-14";
    url = "https://github.com/nixos/nixpkgs/archive/9241cee3c4cc58d77f588a00f5ef6d69c989fd0d.tar.gz";
    sha256 = "sha256:1vsk8i5p1slfh457iqz20w3wgas5vajin3w5wyjcbr58jmn85lff";
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
