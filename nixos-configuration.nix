{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  services.hedgedoc = {
    enable = true;
    settings = {
      domain = "pad.soha.lt";
      protocolUseSSL = true;
    };
  };

  services.hello-server = {
    enable = true;
    port = 1234;
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "pad.soha.lt".extraConfig = ''
        reverse_proxy localhost:${toString config.services.hedgedoc.settings.port}
      '';
      "hello.soha.lt".extraConfig = ''
        reverse_proxy localhost:${toString config.services.hello-server.port}
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  users.users.root.password = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL77PSaQffTINo5ezcZPzcg1/YZq4o30hw8KuMz/pWHm"
  ];

  system.stateVersion = "23.11";
}
