{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/942b0817e898262cc6e3f0a5f706ce09d8f749f1";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (hello.overrideAttrs (oldAttrs: {
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
