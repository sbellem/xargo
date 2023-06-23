{
  description = "xargo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
 
      in
        with pkgs; {

          packages.xargo = rustPlatform.buildRustPackage rec {
            pname = "xargo";
            version = "0.3.22";
            src = builtins.path {
              path = ./.;
              name = "${pname}-${version}";
            };
            cargoSha256 = "sha256-0bRAfTwzq2PFE/CGSkDzQDuyI4t34RkPxaRja/xQFRc=";
            doCheck = false;
            checkPhase = null;
            strictDeps = true;

            buildInputs = [ pkgs.makeWrapper ];

            postInstall = ''
              wrapProgram $out/bin/xargo \
              --set-default RUST_BACKTRACE FULL \
            '';
          };  
          defaultPackage = self.packages.${system}.xargo;

          devShell = mkShell {
            inherit src;

            buildInputs = [
              exa
              fd
              unixtools.whereis
              which
              b2sum
            ];

            RUST_BACKTRACE = 1;
            shellHook = ''
              alias ls=exa
              alias find=fd
            '';
          };
        }
    );
}
