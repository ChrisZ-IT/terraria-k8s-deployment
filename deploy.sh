prompt_var() {
    local var_name="$1" default="$2" prompt="$3" mode="$4"
    local input val

    if [[ "$mode" == "secret" ]]; then
        read -rsp "$prompt: " input
        echo ""
    else
        read -rp "$prompt: " input
    fi

    val="${input:-$default}"

    export "$var_name"="$val"
    echo ""
}

prompt_var SERVER_NAME       "My Server"                "Enter Server name (Default: 'My Server')"
prompt_var PORT              "7777"                     "Enter Server Port (Default: 7777)"
prompt_var COUNT             "8"                        $'Enter max player count (Default: 8 Max: 255)'
prompt_var MOTD              "Welcome to $SERVER_NAME"  $'Enter Server MoTD\n(Default: Welcome to '"$SERVER_NAME"')'
prompt_var WORLD_SIZE        "3"                        $'Enter Wolrd size\n1(small), 2(medium), and 3(large). Default 3'
prompt_var DIFFICULTY        "0"                        $'Enter Wolrd difficulty\n0(classic), 1(expert), 2(master), 3(journey). Default 0'
prompt_var SERVER_PASSWORD   ""                         $'Enter server password (Default: none)' secret

export SERVER_PASSWORD=$(echo -n $SERVER_PASSWORD | base64)

if [ -f "namespace.yml" ]; then
    echo "Applying namespace.yml..."
    kubectl apply -f namespace.yml
fi
for file in *.yml; do
    [ -e "$file" ] || continue
    if [[ "$file" == "deployment.yml" && "$svr_password" == "none" ]]; then
        echo "Applying $file..."
        sed '/-password _DOLLAR_JOIN_PASSWORD/d' "$file" | \
        envsubst | \
        sed 's/_DOLLAR_/\$/g' | kubectl apply -f -
    else
        echo "Applying $file..."
        envsubst < "$file" | sed 's/_DOLLAR_/\$/g' | kubectl apply -f -
    fi
done