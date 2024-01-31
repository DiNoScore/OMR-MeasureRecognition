# NixOS module that configures and runs an inference server
{config, pkgs, lib}:
let
  models = import ./models.nix { inherit pkgs; };
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
