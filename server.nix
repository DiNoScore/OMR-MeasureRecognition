# NixOS module that configures and runs an inference server
{config, pkgs, lib}:
let
  models = import ./models.nix { inherit pkgs; };
  server_app = linkFarm "inference-server" [
    {name = "inference_server.py"; path = ./Python/inference_server.py; }
    {name = "inference_cli.py"; path = ./Python/inference_cli.py; }
  ];
in {
  config = {
    systemd.services.omr-server = {
      description = "Run staff detection on images of music scores as a service";
      wantedBy = [ "multi-user.target" ];

      environment = {
        FLASK_ENV = "production";
        MODELS_DIR = models;
        PYTHONPATH = server_app;
      };

      serviceConfig = rec {
        Type = "simple";
        ExecStart = "gunicorn -b localhost:8000 --timeout=300 --workers=3 --threads=3 inference_server";
        Restart = "on-failure";
        RestartSec = 5;

        # Sandboxing

        DynamicUser = true;

        PrivateDevices = true;
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        CapabilityBoundingSet = [];
        AmbientCapabilities = [];
        
        LockPersonality = true;
        RestrictRealtime = true;
        SystemCallFilter = "@basic-io @aio @file-system @network-io";
        SystemCallArchitectures = "native";
        RestrictAddressFamilies = "AF_INET AF_INET6";
      };
    };
  };
}
