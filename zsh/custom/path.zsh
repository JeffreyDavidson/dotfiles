# Load Composer tools
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Load Node global installed binaries
export PATH="$HOME/.node/bin:$PATH"

# Use project specific binaries before global ones
export PATH="node_modules/.bin:vendor/bin:$PATH"

# Add dotfiles shell scripts to path
export PATH="$HOME/.dotfiles/bin:$PATH"

# Add visual studio code to PATH
if [[ -d "/Applications/Visual Studio Code.app" ]];
    then export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH";
fi
