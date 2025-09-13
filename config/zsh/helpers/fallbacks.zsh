
# Command fallbacks and aliases

# Fix default editor, for systems without nvim installed
if ! hash nvim 2> /dev/null; then
  alias nvim='vim'
fi
