# Ten xkcdpass words separated by spaces.  agenix-rekey's own passphrase
# generator gives six.
{ ... }:
{ pkgs, ... }:
# xkcdpass ends its output with a newline and agenix encrypts stdout as it is.
# A hash or a typed password omits the newline, so a consumer that reads the
# file byte for byte would disagree with both.
"${pkgs.xkcdpass}/bin/xkcdpass --numwords=10 --delimiter=' ' | tr -d '\\n'"
