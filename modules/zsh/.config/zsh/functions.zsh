#!/usr/bin/zsh

# There is deliberately no distro() function here. Nothing in this repository
# parses /etc/os-release: configuration guards on what is present, not on what
# the machine claims to be.
# See docs/adr/0005-single-branch-not-per-distribution.md

# Print $PATH one entry per line.
path() {
  echo -e "${PATH//:/\\n}"
}
