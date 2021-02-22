#!/usr/bin/env bash

# shellcheck disable=SC2034
read -r -d '' __usage <<-'EOF' || true # exits non-zero when EOF encountered
  -f --file [arg]  Config Filename to use
EOF

# shellcheck source=src/runtime/bootstrap/lib/main.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../ && pwd)/runtime/bootstrap/lib/main.sh"

# shellcheck source=src/runtime/bootstrap/lib/ini_val.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../ && pwd)/runtime/bootstrap/lib/ini_val.sh"



function ssh_tunnel() {

    config_file="$1"

    local_tunnel_port="1234"

    ssh_key_path=$(ini_val "$config_file" c12:generated.jumphost_ssh_key_location)
    ssh_host=$(ini_val "$config_file" c12:generated.jumphost_ip)
    ssh_username=$(ini_val "$config_file" c12:generated.jumphost_user)    
    
    ssh -oStrictHostKeyChecking=no -l "$ssh_username" -i "$ssh_key_path" -L "$local_tunnel_port":127.0.0.1:8888 -C -N "$ssh_host" &

    echo "export HTTPS_PROXY=http://127.0.0.1:$local_tunnel_port && export https_proxy=http://127.0.0.1:$local_tunnel_port"
}

config_file="$arg_f"
ssh_tunnel "$config_file"