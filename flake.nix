{
  description = "Container-Nesting";

  nixConfig = {
    substituters = [
      # Add here some other mirror if needed.
      "https://cache.nixos.org/"
    ];
    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Nixpkgs (take the systems nixpkgs version)
    nixpkgs.url = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    # This is a function that generates an attribute by calling a function you
    # pass to it, with the correct `system` and `pkgs` as arguments.
    forAllSystems = func: nixpkgs.lib.genAttrs systems (system: func system nixpkgs.legacyPackages.${system});
  in {
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: pkgs: pkgs.alejandra);

    devShells = forAllSystems (
      system: legacyPkgs: let
        # Import nixpkgs and load it into pkgs.
        pkgs = import nixpkgs {
          inherit system;
        };

        # Things needed only at compile-time.
        nativeBuildInputsBasic = with pkgs; [
          just
          podman
        ];

        githooksBuildInput = with pkgs; [
          git
          curl
          jq
          bash
          unzip
          findutils
          parallel
        ];

        # Things needed at runtime.
        buildInputs = with pkgs; [postgresql];
      in {
        default = pkgs.mkShell {
          inherit buildInputs;
          nativeBuildInputs = nativeBuildInputsBasic ++ githooksBuildInput;
        };
      }
    );
  };
}
