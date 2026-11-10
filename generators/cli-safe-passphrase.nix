# Five hyphen-delimited xkcdpass words of four to seven letters, at most 39
# characters.  Fits a device CLI that caps a password near 48 characters and
# rejects spaces, which long-passphrase does not.
{ ... }:
{ pkgs, ... }:
"${pkgs.xkcdpass}/bin/xkcdpass --numwords=5 --min=4 --max=7 --delimiter=-"
