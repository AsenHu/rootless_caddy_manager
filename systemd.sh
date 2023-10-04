#!/usr/bin/env bash

caddyExe=$1
binPathExe=$2

curl() {
    # Copy from https://github.com/XTLS/Xray-install
    if ! $(type -P curl) -L -q --retry 5 --retry-delay 10 --retry-max-time 60 "$@";then
        echo "ERROR:Curl Failed, check your network"
        exit 1
    fi
}

cp_caddy() {
    local buildVer binVer
    buildVer=$($caddyExe version)
    binVer=$($binPathExe version)
    if [ "$buildVer" ]
    then
        if [ "$buildVer" != "$binVer" ]
        then
            systemctl stop caddy
            rm -rf "$binPathExe"
            groupadd --system caddy
            useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin --comment "Caddy web server" caddy
            curl -o caddy.service https://raw.githubusercontent.com/caddyserver/dist/master/init/caddy.service
            mv ./caddy.service /usr/lib/systemd/system/caddy.service
            systemctl daemon-reload
            systemctl enable --now caddy
        fi
    fi
}

check_update() {
    local dir latest_scr_VERSION local_scr_VERSION
    dir=$(pwd)
    latest_scr_VERSION=$(curl -sL https://github.com/AsenHu/rootless_caddy_manager/raw/main/systemd_version.txt)
    local_scr_VERSION=1.0.0
    if [ "$latest_scr_VERSION" != "$local_scr_VERSION" ]
    then
        rm -rf "$dir/systemd.sh"
        curl -o "$dir/systemd.sh" https://github.com/AsenHu/rootless_caddy_manager/raw/main/systemd.sh
        chmod +x "$dir/systemd.sh"
    fi
}

main() {
    check_update
    cp_caddy
}

main
