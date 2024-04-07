hello-server: {
  config,
  lib,
  ...
}: let
  cfg = config.services.hello-server;
in
  with lib; {
    options = {
      services.hello-server = {
        enable = mkOption {
          type = types.bool;
        };
        port = mkOption {
          type = types.port;
        };
      };
    };
    config = mkIf cfg.enable {
      systemd.services.hello-server = {
        wantedBy = ["multi-user.target"];
        serviceConfig.ExecStart = "${hello-server}/bin/hello-server ${toString cfg.port}";
      };
    };
  }
