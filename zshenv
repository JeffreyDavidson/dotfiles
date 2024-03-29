# Other XDG paths
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="$HOME/.config"}
export STARSHIP_CONFIG="$XDG_CONFIG_HOME"/starship/config.toml

function exists() {
    # `command -v` is similar to `which`
    # https://stackoverflow.com/a/677212/1341838
    command -v $1 >/dev/null 2>&1

    #More explicity written:
    # command -v $1 1>/dev/null 2>/dev/null
}
