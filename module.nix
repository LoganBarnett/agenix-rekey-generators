# Every generator in this repository, declared under age.generators.  Import it
# beside agenix-rekey's own module.  README.org describes the generators.
{ lib, ... }:
let
  generators = import ./generators/default.nix { inherit lib; };
  # agenix-rekey ships hex and base64 of its own.  Ours read an optional length
  # and otherwise match, so they take the definition.
  replacing = [
    "base64"
    "hex"
  ];
in
{
  config.age.generators = lib.mapAttrs (
    name: generator:
    if lib.elem name replacing then lib.mkForce generator else generator
  ) generators;
}
