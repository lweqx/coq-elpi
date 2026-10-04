{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) rocqPackages_9_2;
      rocqPackages = rocqPackages_9_2;
      inherit (rocqPackages.rocq-core) ocamlPackages;
    in
    {
      devShells."${system}" = {
        default = pkgs.mkShell {
          nativeBuildInputs = with ocamlPackages; [
            ocaml
            pkgs.dune
            findlib
            ocaml-lsp
            ocamlformat
            rocqPackages.rocq-core
          ];

          buildInputs = with ocamlPackages; [
            elpi
            findlib
            ppx_optcomp

            rocqPackages.stdlib
            xml-light
          ];

          shellHook = ''
            export PATH="$PWD/.wrappers:$PATH"
            export OCAMLPATH="$PWD/.wrappers:$OCAMLPATH"
          '';
        };
      };

      test = pkgs.mkShell {
        packages = [
          rocqPackages.rocq-core
          (rocqPackages.coq-elpi.overwriteAttrs {
            src = pkgs.fetchFromGitHub {
              owner = "lweqx";
              repo = "coq-elpi";
              ref = "silence-elpi";
              hash = pkgs.lib.fakeHash;
            };
          })
        ];
      };
    };
}
