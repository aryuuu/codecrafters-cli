{
  description = "CodeCrafters CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        version = "v39";
        
        # Map Nix system to CodeCrafters platform/arch naming
        platformArch = {
          x86_64-linux = { os = "linux"; arch = "amd64"; };
          aarch64-linux = { os = "linux"; arch = "arm64"; };
          x86_64-darwin = { os = "darwin"; arch = "amd64"; };
          aarch64-darwin = { os = "darwin"; arch = "arm64"; };
        }.${system} or (throw "Unsupported system: ${system}");
        
        # Hashes for each platform (you'll need to update these)
        hashes = {
          x86_64-linux = "sha256-o3wJ9kMtcnaiQNq/JdTH0/oN8ZWhcwRujkNERj7VxX0=";
          aarch64-linux = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          x86_64-darwin = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          aarch64-darwin = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
        
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "codecrafters";
          inherit version;
          
          src = pkgs.fetchurl {
            url = "https://github.com/codecrafters-io/cli/releases/download/${version}/${version}_${platformArch.os}_${platformArch.arch}.tar.gz";
            sha256 = hashes.${system};
          };
          
          sourceRoot = ".";
          
          installPhase = ''
            mkdir -p $out/bin
            install -m755 codecrafters $out/bin/codecrafters
          '';
          
          meta = with pkgs.lib; {
            description = "CodeCrafters CLI tool";
            homepage = "https://github.com/codecrafters-io/cli";
            license = licenses.mit;
            platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
          };
        };
      }
    );
}
