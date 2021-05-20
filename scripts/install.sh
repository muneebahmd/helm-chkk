#! /bin/bash -e

# Install helm-chkk as Helm plugin by downloading the Chkk CLI package and copying it to
# helm/plugins folder

set -e
# Set $HELM_PLUGIN_DIR as the current working directory
cd $HELM_PLUGIN_DIR

PROJECT_NAME="helm-chkk"
HELM_CHKK_VERSION="$(cat plugin.yaml | grep "version" | cut -d '"' -f 2)"
echo "Installing helm-chkk v${HELM_CHKK_VERSION} ..."



# init_arch discovers the architecture for the target system.
init_arch() {
  ARCH=$(uname -m)
  case $ARCH in
    x86_64) ARCH="amd64";;
    *) ARCH="unknown";;
  esac
}

# init_os discovers the operating system for the target system.
init_os() {
  OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')
}

# verify_supported checks that the os/arch combination is supported for
# Chkk binary packages. Currently supported platforms are:
# (1) linux-amd64
# (2) darwin-amd64
verify_supported() {
  local __supported="linux-amd64\darwin-amd64"
  if ! echo "${__supported}" | grep -q "${OS}-${ARCH}"; then
    echo "No prebuild Chkk binary is supported for target system: ${OS}-${ARCH}."
    exit 1
  fi

  if ! type "curl" >/dev/null 2>&1; then
    echo "curl is required"
    exit 1
  fi
}

# download_package downloads the Chkk CLI package from remote
# repository.
download_package() {
  local __cli_version="0.0.1"
  local __download_url="https://downloads.chkk.dev/v${__cli_version}/chkk-${OS}-${ARCH}"
  echo "Downloading helm-chkk package" 
  curl -sSLo chkk $__download_url
  chmod +x chkk
}

# install_plugin installs the helm-chkk plugin by copying the binary
# to $HELM_PLUGIN_DIR
install_plugin() {
  echo "Preparing to install into ${HELM_PLUGIN_DIR}"
  rm -rf bin && mkdir bin
  mv chkk bin/
  echo "$PROJECT_NAME installed into ${HELM_PLUGIN_DIR}"
}

# catch is executed if an error occurs during installation.
catch() {
  if [ "$1" != "0" ]; then
    echo "Error occurred on line: $2 status: $1"
  fi
}

# test_version verifies the installed plugin is working correctly
# by displaying the help() message.
test_version() {
  PATH=$PATH:$HELM_PLUGIN_PATH
  helm chkk -h
}

# Stop script execution on any error
trap 'catch $? $LINENO' EXIT

init_arch
init_os
verify_supported
download_package
install_plugin
test_version
