#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi


FOLDER_AUR="yay"
KEEP_FOLDER="${KEEP_FOLDER:-0}"

cleanup() {
    echo "Removing folder ${FOLDER_AUR}"
    [[ "${KEEP_FOLDER}" == "1" ]] && return
    [[ -d "${FOLDER_AUR}" ]] && rm -rf "${FOLDER_AUR}"
}
trap cleanup EXIT INT TERM

if [[ $EUID -eq 0 ]]; then
    echo "Error: Run with sudo" >&2
    exit 1
fi

install_packages() {
    echo "Installing packages ....."
    sudo pacman -Syu --needed --noconfirm base-devel git
}

if [[ ! -d "${FOLDER_AUR}" ]]; then
    git clone https://aur.archlinux.org/yay.git
else
    echo "Folder yay exists, skiping clone"
fi

install_packages base-devel git

echo "Makepkg....."
cd "${FOLDER_AUR}" && makepkg -si --noconfirm && cd ..

echo "Version: $(yay --version)"

