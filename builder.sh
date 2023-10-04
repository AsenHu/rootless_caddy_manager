#!/usr/bin/env bash

source ./plugins

install_go_scr() {
    local GO_PATH status tmp errMes
    GO_PATH="$HOME/GO"
    if ! "$GO_PATH/install.sh" version > /dev/null
    then
        tmp=$(bash <(curl https://raw.githubusercontent.com/AsenHu/rootless_go_manager/main/install.sh) @ install "--path=$GO_PATH")
    else
        tmp=$("$GO_PATH/install.sh" @ install "--path=$GO_PATH")
    fi

    status=$(echo "$tmp" |cut -d':' -f1)

    if [ "$status" == "ERROR" ]
    then
        errMes=$(echo "$tmp" |cut -d':' -f2)
        echo "ERROR: $errMes"
        exit 1
    fi

    if [ "$status" == "SCRIPT" ]
    then
        PATH="$PATH:$GO_PATH/go/bin"
    fi
}

curl() {
    # Copy from https://github.com/XTLS/Xray-install
    if ! $(type -P curl) -L -q --retry 5 --retry-delay 10 --retry-max-time 60 "$@";then
        echo "ERROR:Curl Failed, check your network"
        exit 1
    fi
}

build_xcaddy() {
    local local_XCADDY_VERSION latest_XCADDY_VERSION
    latest_XCADDY_VERSION=$(curl -sL https://api.github.com/repos/caddyserver/xcaddy/releases/latest | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
    local_XCADDY_VERSION=$(xcaddy version | awk -F " " '{print $1}')
    if [ "$latest_XCADDY_VERSION" != "$local_XCADDY_VERSION" ]
    then
        go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
    fi
}

build_caddy() {
    local local_CADDY_VERSION latest_CADDY_VERSION i par
    local_CADDY_VERSION=$(caddy version | awk -F " " '{print $1}')
    latest_CADDY_VERSION=$(curl -sL https://api.github.com/repos/caddyserver/caddy/releases/latest | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
    if [ "$latest_CADDY_VERSION" != "$local_CADDY_VERSION" ]
    then
        for i in "${plugins[@]}"
        do
            par=" --with $i$par"
        done
        par="xcaddy build$par"
        $par
    fi
}

check_update() {
    local dir latest_scr_VERSION local_scr_VERSION
    dir=$(pwd)
    latest_scr_VERSION=$(curl -sL https://github.com/AsenHu/rootless_caddy_manager/raw/main/build_version.txt)
    local_scr_VERSION=1.0.0
    if [ "$latest_scr_VERSION" != "$local_scr_VERSION" ]
    then
        rm -rf "$dir/builder.sh"
        curl -o "$dir/builder.sh" "https://raw.githubusercontent.com/AsenHu/rootless_go_manager/main/install.sh"
}

main() {
    check_update
    install_go_scr
    build_xcaddy
    build_caddy
}

main
