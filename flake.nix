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
            "x86_64-linux" = "sha256-rLkgU6XIawU/0iifZmvqZQvSL5icpNMEJs/KTudL16o=";
            "x86_64-darwin" = "sha256-wVJZNhIVoRLekj8fgu1aPOmOqfHdRg87+qmorj7yJwc= ";
            "aarch64-linux" = "sha256-WEBLpR2QN4xrAaHsXzQnR0srtJ8TcTaaJdx2DOIUjxI=";
            "aarch64-darwin" = "sha256-SOE4SeaQVBvMbMwdUR44xX27x0mTJxDWmIgUx7Wsuxs=";
          }."${system}";
        in rec {
          default = pkgs.stdenv.mkDerivation rec {
            name = "acli-${version}";
            version = "1.2.1";

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
