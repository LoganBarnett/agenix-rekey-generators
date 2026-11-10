# Ten xkcdpass words separated by spaces.  agenix-rekey's own passphrase
# generator gives six.
{ ... }:
{ pkgs, ... }:
"${pkgs.xkcdpass}/bin/xkcdpass --numwords=10 --delimiter=' '"
