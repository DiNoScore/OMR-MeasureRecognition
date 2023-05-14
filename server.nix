# NixOS module that configures and runs an inference server
{config, pkgs, lib}:
let
  custom_pkgs = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-2023-05-14";
    url = "https://github.com/nixos/nixpkgs/archive/9241cee3c4cc58d77f588a00f5ef6d69c989fd0d.tar.gz";
    sha256 = "sha256:1vsk8i5p1slfh457iqz20w3wgas5vajin3w5wyjcbr58jmn85lff";
  }) {
    overlays = [
      (import ./overlay.nix)
    ];
  };

  models = import ./models.nix { pkgs = custom_pkgs; };
  server_app = custom_pkgs.python38Packages.callPackage ./server_app.nix {};

  custom_python = custom_pkgs.python38.withPackages (pypkgs: [
    pypkgs.gunicorn
    server_app
  ]);

in {
  config = {
    systemd.services.omr-server = {
      description = "Run staff detection on images of music scores as a service";
      wantedBy = [ "multi-user.target" ];

      environment = {
        FLASK_ENV = "production";
        MODELS_DIR = models;
        # Matplotlib sandboxing workaround. The path can be arbitrary, it won't be written to anyways
        XDG_CONFIG_HOME = "/";
        HOME = "/";
      };

      serviceConfig = rec {
        Type = "simple";
        ExecStart = ''
          ${custom_python}/bin/gunicorn \
            -b localhost:${builtins.toString port} \
            --timeout=300 \
            --workers=2 \
            --threads=2 \
            inference_server:app
        '';
        Restart = "on-failure";
        RestartSec = 60;

        # Sandboxing

        DynamicUser = true;

        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectHostname = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";

        LockPersonality = true;
        RestrictRealtime = true;
        SystemCallFilter = [ "@system-service" ];
        SystemCallArchitectures = "native";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      };
    };
  };
}
