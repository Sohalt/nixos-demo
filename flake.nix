{
  inputs = {
    nixpkgs-hello.url = "github:nixos/nixpkgs/942b0817e898262cc6e3f0a5f706ce09d8f749f1";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-hello,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        hello-pkgs = nixpkgs-hello.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (hello-pkgs.hello.overrideAttrs (oldAttrs: {
              patches = [./hello.patch];
              doCheck = false;
            }))
            cowsay
          ];
          FOO = "bar";
          shellHook = ''
            echo "Happy hacking!"
          '';
        };
      }
    );
}
