#!/bin/bash

##################################################################
##                                                              ##
##          Initialization script for a QAR                     ##
##                                                              ##
##################################################################

case $1 in

  --insecure | --kc | --op)
    ;;
  *)
    echo 1>&2 "$0: secret storage option required"
    exit 2
    ;;
esac


# Change to the name you want to use for your local database environment.
export QAR_NAME="QAR"

# Change to the name you want for the alias for your local QAR AID
export QAR_ALIAS="John Doe"

# Set current working directory for all scripts that must access files
QAR_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

set_passcode() {
  if [ "$1" = "--insecure" ]; then
    head -n 1 passcode >/dev/null 2>&1
    ret=$?
    if [ $ret -eq 1 ]; then
      echo "Generating passcode"
      kli passcode generate > passcode
    fi

  elif [ "$1" = "--op" ]; then
    op vault get QVI >/dev/null 2>&1
    ret=$?
    if [ $ret -eq 1 ]; then
      echo "Generating QVI Vault"
      op vault create QVI >/dev/null 2>&1
    fi

    op item get passcode --vault QVI --fields label=value >/dev/null 2>&1
    ret=$?
    if [ $ret -eq 1 ]; then
      echo "Generating random passcode and storing in 1Password"
      op item create --category password --title "passcode" --vault QVI value="$(kli passcode generate)"  >/dev/null 2>&1
    fi
  elif [ "$1" = "--kc" ]; then
    passcode="$(security find-generic-password -w -a "${LOGNAME}" -s qar-passcode 2> /dev/null)"
    if [ -z "${passcode}" ]; then
      echo "Generating random passcode and storing in Keychain"
      security add-generic-password -a "${LOGNAME}" -s qar-passcode -w "$(kli passcode generate)"
    fi
  fi
}
export -f set_passcode >/dev/null 2>&1

get_passcode() {
  if [ "$1" = "--insecure" ]; then
    echo $(head -n 1 passcode)
  elif [ "$1" = "--op" ]; then
    echo $(op item get passcode --vault QVI --fields label=value)
  elif [ "$1" = "--kc" ]; then
    echo $(security find-generic-password -w -a "${LOGNAME}" -s qar-passcode)
  fi
}
export -f get_passcode >/dev/null 2>&1

set_salt() {
    if [ "$1" = "--insecure" ]; then
      head -n 1 salt >/dev/null 2>&1
      ret=$?
      if [ $ret -eq 1 ]; then
        echo "Generating salt"
        kli salt > salt
      fi
    elif [ "$1" = "--op" ]; then
      op vault get QVI >/dev/null 2>&1
      ret=$?
      if [ $ret -eq 1 ]; then
        echo "Generating QVI Vault"
        op vault create QVI >/dev/null 2>&1
      fi

      op item get salt --vault QVI --fields label=value >/dev/null 2>&1
      ret=$?
      if [ $ret -eq 1 ]; then
        echo "Generating random salt and storing in 1Password"
        op item create --category password --title "salt" --vault QVI value="$(kli salt)"  >/dev/null 2>&1
      fi
    elif [ "$1" = "--kc" ]; then
      salt="$(security find-generic-password -w -a "${LOGNAME}" -s ext-gar-salt 2> /dev/null)"
      if [ -z "${salt}" ]; then
        echo "Generating random salt and storing in Keychain"
        security add-generic-password -a "${LOGNAME}" -s ext-gar-salt -w "$(kli salt)"
      fi
    fi
}

get_salt() {
  if [ "$1" = "--insecure" ]; then
    echo $(head -n 1 salt)
  elif [ "$1" = "--op" ]; then
    echo $(op item get salt --vault QVI --fields label=value)
  elif [ "$1" = "--kc" ]; then
    echo $(security find-generic-password -w -a "${LOGNAME}" -s qar-salt)
  fi
}
export -f get_salt >/dev/null 2>&1

set_passcode $1
set_salt $1
