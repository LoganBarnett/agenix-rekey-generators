{ lib, pkgs }:
let
  # agenix-rekey declares age.generators.  This stands in for it with a type
  # that rejects two definitions of one name unless a priority separates them,
  # which is the behaviour the replacements rely on.
  stub = {
    options.age.generators = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = { };
    };
  };
  upstream.age.generators = {
    base64 = _: "upstream base64";
    hex = _: "upstream hex";
    passphrase = _: "upstream passphrase";
  };
  configOf =
    modules:
    (lib.evalModules {
      modules = [
        stub
        ../module.nix
      ]
      ++ modules;
    }).config.age.generators;
  generators = configOf [ upstream ];
  declared = lib.attrNames (import ../generators/default.nix { inherit lib; });
  stubSecret = {
    inherit pkgs;
    secret.settings = { };
  };
in
{
  testModuleDeclaresEveryGenerator = {
    expr = lib.all (name: generators ? ${name}) declared;
    expected = true;
  };
  testUpstreamGeneratorsSurvive = {
    expr = generators.passphrase { };
    expected = "upstream passphrase";
  };
  testHexReplacesUpstream = {
    expr = lib.hasInfix "openssl rand -hex 24" (generators.hex stubSecret);
    expected = true;
  };
  testBase64ReplacesUpstream = {
    expr = lib.hasInfix "openssl rand --base64 32" (
      generators.base64 stubSecret
    );
    expected = true;
  };
}
