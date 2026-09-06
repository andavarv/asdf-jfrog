#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/jfrog/jfrog-cli"
TOOL_NAME="jfrog"
TOOL_TEST="jf --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

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
		sed 's/^v//'
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local version="$1"
	local download_path="$2"
	local CLI_OS="na"
	local CLI_MAJOR_VER="v2-jf"
	local VERSION="$version"

	echo "Downloading JFrog CLI version ${VERSION}..."

	if $(echo "${OSTYPE}" | grep -q msys); then
		CLI_OS="windows"
		FILE_NAME="jf.exe"
		URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-windows-amd64/${FILE_NAME}"
	elif $(echo "${OSTYPE}" | grep -q darwin); then
		CLI_OS="mac"
		FILE_NAME="jf"
		MACHINE_TYPE="$(uname -m)"
		case $MACHINE_TYPE in
		arm64)
			ARCH="arm64"
			;;
		x86_64 | amd64)
			ARCH="amd64"
			;;
		*)
			fail "Unknown machine type: $MACHINE_TYPE"
			;;
		esac
		URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-${CLI_OS}-${ARCH}/${FILE_NAME}"
	else
		CLI_OS="linux"
		FILE_NAME="jf"
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
			fail "Unknown machine type: $MACHINE_TYPE"
			;;
		esac
		URL="https://releases.jfrog.io/artifactory/jfrog-cli/${CLI_MAJOR_VER}/${VERSION}/jfrog-cli-${CLI_OS}-${ARCH}/${FILE_NAME}"
	fi

	curl -XGET "$URL" -L -k -g >"$download_path/$FILE_NAME" || fail "Could not download $URL"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"
	local FILE_NAME="jf"

	if $(echo "${OSTYPE}" | grep -q msys); then
		FILE_NAME="jf.exe"
	fi

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"
		chmod u+x "$install_path/$FILE_NAME"

		test -x "$install_path/$FILE_NAME" || fail "Expected $install_path/$FILE_NAME to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}