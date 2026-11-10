# Shared by the TLS generators.  A subject is the attrset under
# settings.tls.subject.  Validation names the missing field instead of failing
# on an attribute lookup deep inside a shell string.  Each lookup falls back to
# null so a missing field reaches the throw and not Nix's own error, which
# tryEval cannot catch.  Each validator returns id once it passes, so a
# generator applies it to its script.
{ lib }:
let
  inherit (lib) isAttrs isInt isString;
  inherit (lib.trivial) id throwIfNot;
in
rec {
  subjectString = subject: ''
    /C=${subject.country}\
    /ST=${subject.state}\
    /L=${subject.location}\
    /O=${subject.organization}\
    /OU=${subject.organizational-unit}'';

  validateSubject =
    name: subject:
    throwIfNot (isAttrs subject)
      "Secret '${name}' must have a `tls.subject` attrset."
      throwIfNot
      (isString (subject.country or null))
      "Secret '${name}' must have a `tls.subject.country` string."
      throwIfNot
      (isString (subject.state or null))
      "Secret '${name}' must have a `tls.subject.state` string."
      throwIfNot
      (isString (subject.location or null))
      "Secret '${name}' must have a `tls.subject.location` string."
      throwIfNot
      (isString (subject.organization or null))
      "Secret '${name}' must have a `tls.subject.organization` string."
      throwIfNot
      (isString (subject.organizational-unit or null))
      "Secret '${name}' must have a `tls.subject.organizational-unit` string."
      id;

  validateSettings =
    name: tls:
    throwIfNot (isAttrs tls) "Secret '${name}' must have a `tls` attrset."
      throwIfNot
      (isString (tls.domain or null))
      "Secret '${name}' must have a `tls.domain` string."
      throwIfNot
      (isInt (tls.validity or null))
      "Secret '${name}' must have a `tls.validity` integer."
      validateSubject
      name
      (tls.subject or null)
      id;
}
