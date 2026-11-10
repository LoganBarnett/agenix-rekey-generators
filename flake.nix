{
  description = "Secret generators for agenix-rekey.";

  inputs = {
    nixfmt-strict-width = {
      url = "github:LoganBarnett/nixfmt-strict-width";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    org-fmt = {
      url = "github:LoganBarnett/org-fmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixfmt-strict-width,
      nixpkgs,
      org-fmt,
    }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      # A path and not an imported value.  The module system can only
      # deduplicate a module imported twice when it is a path.
      module = ./module.nix;
    in
    {
      # The module sets no class, so one file serves every platform
      # agenix-rekey supports.
      darwinModules.default = module;
      homeManagerModules.default = module;
      nixosModules.default = module;

      # The generators as plain functions, for a flake that wants one without
      # the module.
      lib.generators = import ./generators/default.nix { inherit lib; };

      checks = forAllSystems (
        system:
        import ./tests/default.nix {
          inherit lib;
          pkgs = nixpkgs.legacyPackages.${system};
          generators = self.lib.generators;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              # Lint GitHub Action files.
              pkgs.actionlint
              # Include a Nix formatter that uses real width instead of
              # post-indented width for width calculations.
              nixfmt-strict-width.packages.${system}.default
              # Format org-mode files.
              org-fmt.packages.${system}.default
              # Generic formatter that can handle the entire tree.
              pkgs.treefmt
            ];
          };
        }
      );
    };
}
