#!/usr/bin/zsh

# Show the current distribution
distro() {
  dtype="unknown" # Default to unknown

  # Use /etc/os-release for modern distro identification
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    case $ID in
    fedora | rhel | centos)
      dtype="redhat"
      ;;
    sles | opensuse*)
      dtype="suse"
      ;;
    ubuntu | debian)
      dtype="debian"
      ;;
    gentoo)
      dtype="gentoo"
      ;;
    arch | manjaro)
      dtype="arch"
      ;;
    slackware)
      dtype="slackware"
      ;;
    *)
      # Check ID_LIKE only if dtype is still unknown
      if [ -n "$ID_LIKE" ]; then
        case $ID_LIKE in
        *fedora* | *rhel* | *centos*)
          dtype="redhat"
          ;;
        *sles* | *opensuse*)
          dtype="suse"
          ;;
        *ubuntu* | *debian*)
          dtype="debian"
          ;;
        *gentoo*)
          dtype="gentoo"
          ;;
        *arch*)
          dtype="arch"
          ;;
        *slackware*)
          dtype="slackware"
          ;;
        esac
      fi

      # If ID or ID_LIKE is not recognized, keep dtype as unknown
      ;;
    esac
  fi

  echo $dtype
}

path() {
  echo -e "${PATH//:/\\n}"
}
