{
  description = "Atlassian CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {self, nixpkgs, ...}:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          downloadPathPartArchitecture = {
            "x86_64-linux" = "linux_amd64";
            "x86_64-darwin" = "darwin_amd64";
            "aarch64-linux" = "linux_arm64";
            "aarch64-darwin" = "darwin_arm64";
          }."${system}";
          downloadPathPartOs = {
            "x86_64-linux" = "linux";
            "x86_64-darwin" = "darwin";
            "aarch64-linux" = "linux";
            "aarch64-darwin" = "darwin";
          }."${system}";
          checksum = {
            "x86_64-linux" = "sha256-XEyz5gOZKvGpG8FBbWzOTW2/LutZzBGXyx2LYRLYqB4=";
            "x86_64-darwin" = "sha256-ibYBetUKGkn7Qf0Nq6nV9h+BLnblCUpFLt6w3bwZ8rE=";
            "aarch64-linux" = "sha256-dtf4wDQ6Grtk0yAMO0GYd9GKwyvrHJvELdWiHw4neJ4=";
            "aarch64-darwin" = "sha256-0gSzFOFzr3wz6p5SjShtCEbdya+cmpSyjSekBu+rRiU=";
          }."${system}";
        in rec {
          default = pkgs.stdenv.mkDerivation rec {
            name = "acli-${version}";
            version = "1.1.0";

            src = pkgs.fetchzip {
              url = "https://acli.atlassian.com/${downloadPathPartOs}/${version}-stable/acli_${version}-stable_${downloadPathPartArchitecture}.tar.gz";
              stripRoot = true;
              sha256 = checksum;
            };

            sourceRoot = "./source";

            dontFixup = true;

            installPhase = ''
              runHook preInstall
              install -m755 -D acli $out/bin/acli
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              homepage = "https://developer.atlassian.com/cloud/acli/guides/introduction/";
              description = "Atlassian CLI";
              platforms = platforms.linux ++ platforms.darwin;
            };
          };
        }
      );
      apps = forAllSystems (system:
        {
          default = {
            type = "app";
            program = "${self.packages."${system}".default}/bin/acli";
          };
        }
      );
    };
}
