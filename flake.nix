{
  inputs = {
    nixpkgs-hello.url = "github:nixos/nixpkgs/942b0817e898262cc6e3f0a5f706ce09d8f749f1";
    utils.url = "github:numtide/flake-utils";
    clj-nix.url = "github:jlesquembre/clj-nix";
    disko.url = "github:nix-community/disko";
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-hello,
    clj-nix,
    disko,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [clj-nix.overlays.default];
        };
        hello-pkgs = nixpkgs-hello.legacyPackages.${system};
        hello-rc = hello-pkgs.hello.overrideAttrs (oldAttrs: {
          patches = [./hello.patch];
          doCheck = false;
        });
        hello-server = pkgs.mkCljBin {
          projectSrc = ./server;
          name = "hello-server";
          version = "1.0";
          main-ns = "hello-server";
          nativeBuildInputs = [pkgs.makeWrapper];
          postInstall = ''
            wrapProgram $binaryPath --prefix PATH : $out/bin:${nixpkgs.lib.makeBinPath [hello-rc]}
            chmod +x $out/bin/*
          '';
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            cowsay
            hello-rc
            clojure
            clj-nix.packages.${system}.deps-lock
          ];
          FOO = "bar";
          shellHook = ''
            echo "Happy hacking!"
          '';
        };
        packages = {
          hello-rc = hello-rc;
          hello-server = hello-server;
          make-docker-image = pkgs.dockerTools.streamLayeredImage {
            name = "hello-server";
            config.Cmd = ["${hello-server}/bin/hello-server" "8080"];
          };
        };
      }
    )
    // {
      nixosConfigurations.demo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {imports = [./nixos-configuration.nix];}
          disko.nixosModules.disko
        ];
      };
    };
}
