#!/usr/bin/env bash

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for jfrog.
GH_REPO="https://github.com/jfrog/jfrog-cli"
TOOL_NAME="jfrog"
TOOL_TEST="jfrog --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if jfrog is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	# TODO: Adapt this. By default we simply list the tag names from GitHub releases.
	# Change this function if jfrog has other means of determining installable versions.
	list_github_tags
}

download_release() {
	local version="$1"
	local download_path="$2"
	local CLI_OS="na"

	if [ -z "$3" ]; then
		CLI_MAJOR_VER="$3"
	else
		CLI_MAJOR_VER="v1"
	fi

	if [ $3 == "v2" ]; then
		CLI_MAJOR_VER="v2"
		VERSION="$1"
		echo "Downloading the latest v2 version of JFrog CLI..."
	elif [ $3 == "v2" ]; then
		CLI_MAJOR_VER="v2"
		VERSION=$2
		echo "Downloading version $2 of JFrog CLI..."
	elif [ $# -eq 0 ]; then
		VERSION="[RELEASE]"
		echo "Downloading the latest v1 version of JFrog CLI..."
	else
		VERSION=$1
		echo "Downloading version $1 of JFrog CLI..."
	fi
	if $(echo "${OSTYPE}" | grep -q msys); then
		CLI_OS="windows"
		URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-windows-amd64/jfrog.exe"
		FILE_NAME="jfrog.exe"
	elif $(echo "${OSTYPE}" | grep -q darwin); then
		CLI_OS="mac"
		URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-mac-386/jfrog"
		FILE_NAME="jfrog"
	else
		CLI_OS="linux"
		MACHINE_TYPE="$(uname -m)"
		case $MACHINE_TYPE in
		i386 | i486 | i586 | i686 | i786 | x86)
			ARCH="386"
			;;
		amd64 | x86_64 | x64)
			ARCH="amd64"
			;;
		arm | armv7l)
			ARCH="arm"
			;;
		aarch64)
			ARCH="arm64"
			;;
		s390x)
			ARCH="s390x"
			;;
		ppc64)
			ARCH="ppc64"
			;;
		ppc64le)
			ARCH="ppc64le"
			;;
		*)
			echo "Unknown machine type: $MACHINE_TYPE"
			exit -1
			;;
		esac
		URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-${CLI_OS}-${ARCH}/jfrog"
		FILE_NAME="jfrog"
	fi

	curl -XGET "$URL" -L -k -g >"$download_path/$FILE_NAME" || fail "Could not download $URL"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"
	local FILE_NAME="jfrog"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"
		chmod u+x "$install_path/$FILE_NAME"

		# TODO: Assert jfrog executable exists.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
