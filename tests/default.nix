{
  lib,
  pkgs,
  generators,
}:
let
  # A failing suite stops evaluation, so the failed cases print without a
  # build log to dig through.
  suite =
    name: cases:
    let
      failed = lib.runTests cases;
    in
    if failed == [ ] then
      pkgs.emptyFile
    else
      throw "${name} tests failed:\n${lib.generators.toPretty { } failed}";
in
{
  generators = suite "generators" (
    import ./generators.nix { inherit lib pkgs generators; }
  );
  module = suite "module" (import ./module.nix { inherit lib pkgs; });
}
