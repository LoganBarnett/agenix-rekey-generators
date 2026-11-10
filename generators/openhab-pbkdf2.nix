# An openHAB admin entry for jsondb/users.json, with the first dependency as
# the password hashed by PBKDF2WithHmacSHA512.
#
# The parameters match openHAB's UserRegistryImpl.java constants.  65536
# iterations, a 64 byte key, and a 64 byte salt.  openHAB stores the salt as
# base64 and hashes with the UTF-8 bytes of that base64 string, not the decoded
# bytes.  UserRegistryImpl.hash() does `salt.getBytes()`.
{ lib }:
{
  decrypt,
  deps,
  pkgs,
  ...
}:
let
  passwordDep = builtins.head deps;
  # Python script written to the Nix store for clean quoting.
  script = pkgs.writeText "openhab-pbkdf2.py" ''
    import hashlib, base64, os, json, sys
    password = sys.argv[1].strip()
    salt_bytes = os.urandom(64)
    salt_b64 = base64.b64encode(salt_bytes).decode()
    # openHAB hashes using the UTF-8 bytes of the base64 salt string, not the
    # decoded bytes.  Match UserRegistryImpl.hash(): salt.getBytes().
    hash_bytes = hashlib.pbkdf2_hmac('sha512', password.encode(), salt_b64.encode(), 65536, 64)
    hash_b64 = base64.b64encode(hash_bytes).decode()
    print(json.dumps({
      'admin': {
        'class': 'org.openhab.core.auth.ManagedUser',
        'value': {
          'name': 'admin',
          'passwordHash': hash_b64,
          'passwordSalt': salt_b64,
          'roles': ['administrator'],
          'sessions': [],
          'apiTokens': [],
        }
      }
    }))
  '';
in
''
  ${pkgs.python3}/bin/python3 ${script} \
    "$(${decrypt} ${lib.escapeShellArg passwordDep.file})"
''
