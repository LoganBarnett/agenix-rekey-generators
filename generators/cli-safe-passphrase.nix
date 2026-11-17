# Five hyphen-delimited xkcdpass words of four to seven letters, at most 39
# characters.  Fits a device CLI that caps a password near 48 characters and
# rejects spaces, which long-passphrase does not.
{ ... }:
{ pkgs, ... }:
# xkcdpass ends its output with a newline and agenix encrypts stdout as it is.
# A hash or a typed password omits the newline, so a consumer that reads the
# file byte for byte would disagree with both.
"${pkgs.xkcdpass}/bin/xkcdpass --numwords=5 --min=4 --max=7 --delimiter=-"
+ " | tr -d '\\n'"
