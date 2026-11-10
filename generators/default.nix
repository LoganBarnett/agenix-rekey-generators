# Every generator by name.  Each file is a function from lib to the generator
# agenix-rekey calls.  The list is written out so a new generator is a
# deliberate addition and not a side effect of a file landing.
{ lib }:
let
  generator = path: import path { inherit lib; };
in
{
  attic-server-jwt-environment-file =
    generator
      ./attic-server-jwt-environment-file.nix;
  base64 = generator ./base64.nix;
  base64url = generator ./base64url.nix;
  cli-safe-passphrase = generator ./cli-safe-passphrase.nix;
  environment-file = generator ./environment-file.nix;
  environment-variable = generator ./environment-variable.nix;
  hex = generator ./hex.nix;
  htpasswd = generator ./htpasswd.nix;
  long-passphrase = generator ./long-passphrase.nix;
  long-passphrase-hashed = generator ./long-passphrase-hashed.nix;
  nix-cache-signing-key = generator ./nix-cache-signing-key.nix;
  openhab-pbkdf2 = generator ./openhab-pbkdf2.nix;
  rsa-private-key = generator ./rsa-private-key.nix;
  slapd-hashed = generator ./slapd-hashed.nix;
  ssh-ed25519-with-pub = generator ./ssh-ed25519-with-pub.nix;
  stalwart-dkim-key = generator ./stalwart-dkim-key.nix;
  template-file = generator ./template-file.nix;
  tls-ca-root = generator ./tls-ca-root.nix;
  tls-signed-certificate = generator ./tls-signed-certificate.nix;
  wireguard-priv = generator ./wireguard-priv.nix;
  yaml-secret-file = generator ./yaml-secret-file.nix;
}
