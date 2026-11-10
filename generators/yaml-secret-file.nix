# A flat YAML file with one key per dependency.  The key is the dependency's
# settings.fieldName or its secret name, and the value is its plaintext.
# Values are not escaped, so this is for values with no YAML syntax in them.
# Home Assistant's secrets.yaml is the consumer this was written for.
{ lib }:
{ decrypt, deps, ... }:
lib.strings.concatLines (
  map (dep: ''
    echo '${dep.settings.fieldName or dep.name}: '"$(${decrypt} ${
      lib.escapeShellArg dep.file
    })"
  '') deps
)
