#!/usr/bin/env bash
# Copyright © 2021 Chkk <support@chkk.io>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
  local __cli_version=`curl -sS https://get.chkk.dev/cli/latest.txt`
  local __download_url="https://get.chkk.dev/${__cli_version}/chkk-${OS}-${ARCH}"
  echo "Downloading helm-chkk package" 
  curl -sSLo helm-chkk $__download_url
  chmod +x helm-chkk
}

# install_plugin installs the helm-chkk plugin by copying the binary
# to $HELM_PLUGIN_DIR
install_plugin() {
  echo "Preparing to install into ${HELM_PLUGIN_DIR}"
  rm -rf bin && mkdir bin
  mv helm-chkk bin/
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
