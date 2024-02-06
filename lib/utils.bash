#!/usr/bin/env bash

set -euo pipefail

REPO="smithy-lang/smithy"
GH_REPO="https://github.com/$REPO"
GH_REPO_API="https://api.github.com/repos/$REPO"
TOOL_NAME="smithy"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# Append token if exists to prevent throttling
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

# run a check on commands needed to proceed
check() {
  for cmd in "$@"; do
    if ! [ -x "$(command -v "$cmd")" ]; then
      fail "$cmd is not installed, please install it before proceeding."
    fi
  done
}

# get list of versions from GH-Releases, sorted by created date
list_all_versions() {
  check jq
  (curl "${curl_opts[@]}" $GH_REPO_API/releases |
    jq -r 'sort_by(.created_at) | .[] | select (.prerelease == false) | select (.assets | length > 0) | .tag_name') ||
    fail "Could not list versions."
}

# get platform, output it as lowercase
get_platform() {
  uname | tr '[:upper:]' '[:lower:]'
}

# get architecture, output it, quit if unsupported
get_arch() {
  arch="$(uname -m)"
  if [[ ! $(check_arch "$arch") ]]; then
    fail "unsupported architecture ($arch)"
  fi
  echo "$arch"
}

# check architecture, output it if supported, else nothing
check_arch() {
  case "$1" in
    x86_64 | aarch64) echo "$1" ;;
    *) return ;;
  esac
}

# get the url for the artifact to download, based on
# the system (1st arg) and the version (2nd arg)
get_artifact_url() {
  check jq
  if [ "$#" -gt 1 ]; then
    local tag
    if [ "$2" = "latest" ]; then
      # get the latest release and get the tag
      tag=$(curl "${curl_opts[@]}" $GH_REPO_API/releases/latest | jq -r '.tag_name')
    else
      tag=$2
    fi
    echo "$GH_REPO/releases/download/$tag/smithy-cli-$1.zip"
  else
    fail "platform or version were not specified."
  fi
}

# download the release, and unpack it without creating any
# temporary files
download_release() {
  local type version path url
  type="$1"
  version="$2"
  path="$3"

  if [ "$type" = "version" ]; then
    echo "* Downloading $TOOL_NAME release ($version)..."
    url=$(get_artifact_url "$(get_platform)-$(get_arch)" "$version")
    if [ "$url" ]; then
      mkdir -p "$path"
      curl "${curl_opts[@]}" "$url" | tar xzf - -C "$path" --strip-components 1 ||
        fail "Request to '$url' returned bad response ($?)."
    else
      fail "Could not form url."
    fi
  else
    fail "Download by '$type' is not supported."
  fi
}

verify_tool() {
  tool_cmd="$1"
  bash -c "$tool_cmd --help > /dev/null" || fail "Expected '$tool_cmd' to be executable."
  bash -c "$tool_cmd warmup" || fail "Expected '$tool_cmd warmup' to run."
}

install_version() {
  local type version download_path path
  type="$1"
  version="$2"
  download_path="$3"
  path="$4"

  if [ "$type" != "version" ]; then
    fail "Install by '$type' is not supported."
  fi

  (
    mkdir -p "$path"
    # zips don't maintain permissions, so we need to add x perms to the right files
    chmod +x "$download_path"/bin/* "$download_path"/lib/jspawnhelper
    cp -r "$download_path"/* "$path"

    # assert smithy exists and runs
    echo "* Verifying installation..."
    verify_tool "$path/bin/$TOOL_NAME"

    # clean up the download ourselves, there may be
    # write-protected files that are troublesome for
    # asdf-tooling to delete for us
    echo "* Cleaning up..."
    rm -rf "$download_path"
    echo "$TOOL_NAME ($version) installation was successful!"
  ) || (
    rm -rf "$path"
    fail "An error occurred while installing $TOOL_NAME ($version)."
  )
}
