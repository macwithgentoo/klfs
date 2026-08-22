#!/usr/bin/env bash
# Built with Google Gemini
set -euo pipefail

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}Checking host distribution for KLFS build...${RESET}"

# 1. Verify Gentoo host
if [ -f /etc/gentoo-release ]; then
    GENTOO_VER=$(cat /etc/gentoo-release)
    echo -e "[${GREEN}PASS${RESET}] Host detected: ${GENTOO_VER}"
else
    echo -e "[${YELLOW}WARNING${RESET}] Host is not Gentoo Linux."
    echo -e "          Gentoo is strongly recommended so you can leverage the pre-compiled 'gentoo-kernel-bin'."
    read -p "Do you want to proceed anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Aborted by user.${RESET}"
        exit 1
    fi
fi

# 2. Check for binary kernel package on Gentoo
if [ -f /etc/gentoo-release ]; then
    echo -e "\n${BOLD}Checking for Gentoo binary kernel...${RESET}"
    if qlist -I sys-kernel/gentoo-kernel-bin &>/dev/null || [ -d /var/db/pkg/sys-kernel/gentoo-kernel-bin-* ]; then
        echo -e "  [${GREEN}OK${RESET}] sys-kernel/gentoo-kernel-bin is installed."
    else
        echo -e "  [${YELLOW}INFO${RESET}] sys-kernel/gentoo-kernel-bin not found."
        echo -e "          You can install it on your Gentoo host using:"
        echo -e "          ${BOLD}emerge --ask sys-kernel/gentoo-kernel-bin${RESET}"
    fi
fi

# 3. Check essential build tools
echo -e "\n${BOLD}Checking essential build dependencies...${RESET}"

REQUIRED_TOOLS=(
    "gcc"
    "g++"
    "make"
    "bison"
    "flex"
    "gawk"
    "patch"
    "tar"
    "xz"
)

MISSING=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo -e "  [${GREEN}OK${RESET}] $tool"
    else
        echo -e "  [${RED}MISSING${RESET}] $tool"
        MISSING+=("$tool")
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo -e "\n${RED}Error:${RESET} Missing required tools: ${MISSING[*]}"
    if [ -f /etc/gentoo-release ]; then
        echo -e "Install missing tools on Gentoo with:"
        echo -e "${BOLD}emerge --ask sys-devel/gcc sys-devel/make sys-devel/bison sys-devel/flex sys-apps/gawk sys-devel/patch${RESET}"
    fi
    exit 1
fi

echo -e "\n${GREEN}${BOLD}Host environment check passed successfully!${RESET}"
