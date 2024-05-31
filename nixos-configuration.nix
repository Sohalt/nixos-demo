{pkgs, ...}: {
  users.users.root.password = "";

  environment.systemPackages = [
    pkgs.curl
    pkgs.gitMinimal
  ];

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL77PSaQffTINo5ezcZPzcg1/YZq4o30hw8KuMz/pWHm"
  ];

  system.stateVersion = "23.11";
}
