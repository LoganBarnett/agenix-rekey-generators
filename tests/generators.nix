{
  lib,
  pkgs,
  generators,
}:
let
  dep = name: {
    inherit name;
    host = "nixos:example";
    file = "./secrets/${name}.age";
  };
  subject = {
    country = "US";
    state = "State";
    location = "City";
    organization = "Example";
    organizational-unit = "IT";
  };
  tls = {
    domain = "example.internal";
    inherit subject;
    validity = 365;
  };

  # What each generator needs from its secret.  A generator with no entry here
  # fails testEveryGeneratorHasAFixture, so a new one cannot land untested.
  fixtures = {
    attic-server-jwt-environment-file = { };
    base64 = { };
    base64url = { };
    cli-safe-passphrase = { };
    environment-file.deps = [
      (dep "a")
      (dep "b")
    ];
    environment-variable = {
      settings.field = "TOKEN";
      deps = [ (dep "token") ];
    };
    hex = { };
    htpasswd = {
      settings.username = "ada";
      deps = [ (dep "password") ];
    };
    long-passphrase = { };
    long-passphrase-hashed.deps = [ (dep "passphrase") ];
    nix-cache-signing-key.settings.keyName = "cache.example:1";
    openhab-pbkdf2.deps = [ (dep "admin-password") ];
    rsa-private-key = { };
    slapd-hashed.deps = [ (dep "password") ];
    ssh-ed25519-with-pub = { };
    stalwart-dkim-key = { };
    template-file = {
      settings.template = "token=%token%";
      deps = [ (dep "token") ];
    };
    tls-ca-root.settings.tls = tls;
    tls-signed-certificate = {
      settings = {
        fqdn = "ldap.example.internal";
        root-certificate.settings.tls = tls;
      };
      deps = [ (dep "root") ];
    };
    wireguard-priv = { };
    yaml-secret-file.deps = [
      (dep "a")
      (dep "b")
    ];
  };

  decrypt = "/stub/decrypt";
  gitAdd = "/stub/git-add";
  # The arguments agenix-rekey passes, with a stub wherever a real run puts a
  # command.  settings travels on the secret and alone, as upstream and the
  # fork pass it.
  render =
    name: fixture:
    let
      settings = fixture.settings or { };
    in
    generators.${name} {
      inherit
        pkgs
        lib
        name
        decrypt
        gitAdd
        settings
        ;
      file = "./secrets/${name}.age";
      secret = {
        inherit settings;
      };
      deps = fixture.deps or [ ];
    };
  scripts = lib.mapAttrs render fixtures;
  names = predicate: lib.attrNames (lib.filterAttrs (_: predicate) scripts);
  rejects = value: !(builtins.tryEval (builtins.deepSeq value value)).success;

  # Generators that write a file beside the secret.  Each must hand it to
  # gitAdd, and no other generator may mention gitAdd.
  writesCompanion = [
    "nix-cache-signing-key"
    "ssh-ed25519-with-pub"
    "stalwart-dkim-key"
    "tls-ca-root"
    "tls-signed-certificate"
    "wireguard-priv"
  ];
in
{
  testEveryGeneratorHasAFixture = {
    expr = lib.attrNames generators;
    expected = lib.attrNames fixtures;
  };
  testEveryGeneratorRendersAScript = {
    expr = lib.mapAttrs (
      _: script: lib.isString script && script != ""
    ) scripts;
    expected = lib.mapAttrs (_: _: true) fixtures;
  };
  testCompanionGeneratorsCallGitAdd = {
    expr = names (lib.hasInfix gitAdd);
    expected = writesCompanion;
  };
  testDependentGeneratorsDecrypt = {
    expr = names (lib.hasInfix decrypt);
    expected = lib.attrNames (
      lib.filterAttrs (_: fixture: (fixture.deps or [ ]) != [ ]) fixtures
    );
  };

  testHexDefaultMatchesUpstream = {
    expr = lib.hasInfix "-hex 24" scripts.hex;
    expected = true;
  };
  testHexReadsLength = {
    expr = lib.hasInfix "-hex 8" (render "hex" { settings.length = 8; });
    expected = true;
  };
  testBase64DefaultMatchesUpstream = {
    expr = lib.hasInfix "--base64 32" scripts.base64;
    expected = true;
  };
  testTemplatePlaceholderFollowsTheDependencyName = {
    expr = lib.hasInfix "%other%" (
      render "template-file" {
        settings.template = "unrelated";
        deps = [ (dep "other") ];
      }
    );
    expected = true;
  };

  testTlsRootNamesAMissingSubjectField = {
    expr = rejects (
      render "tls-ca-root" {
        settings.tls = tls // {
          subject = removeAttrs subject [ "country" ];
        };
      }
    );
    expected = true;
  };
  testTlsRootNeedsAnIntegerValidity = {
    expr = rejects (
      render "tls-ca-root" {
        settings.tls = tls // {
          validity = "365";
        };
      }
    );
    expected = true;
  };
  testSignedCertificateDefaultsToFortySevenDays = {
    expr = lib.hasInfix "-days 47 " scripts.tls-signed-certificate;
    expected = true;
  };
  testSignedCertificateReadsValidity = {
    expr = lib.hasInfix "-days 90 " (
      render "tls-signed-certificate" (
        fixtures.tls-signed-certificate
        // {
          settings = fixtures.tls-signed-certificate.settings // {
            validity = 90;
          };
        }
      )
    );
    expected = true;
  };
  testSignedCertificateNeedsAnIntegerValidity = {
    expr = rejects (
      render "tls-signed-certificate" (
        fixtures.tls-signed-certificate
        // {
          settings = fixtures.tls-signed-certificate.settings // {
            validity = "90";
          };
        }
      )
    );
    expected = true;
  };
  testSignedCertificateNeedsAnFqdn = {
    expr = rejects (
      render "tls-signed-certificate" {
        settings.root-certificate.settings.tls = tls;
        deps = [ (dep "root") ];
      }
    );
    expected = true;
  };
  testNixCacheKeyNeedsAKeyName = {
    expr = rejects (render "nix-cache-signing-key" { });
    expected = true;
  };
}
