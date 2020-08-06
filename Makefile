.PHONY: install macos brew brew-restore

# Run dotbot install script
install:
	./install

# Save snapshot of all Homebrew packages to homebrew/Brewfile
brew:
	brew bundle dump -f --file=homebrew/Brewfile
	brew bundle --force cleanup --file=homebrew/Brewfile

# Restore Homebrew packages
brew-restore:
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew update
	brew upgrade
	brew install mas
	brew bundle install --file=homebrew/Brewfile
	brew cleanup

# Set MacOS defaults
macos:
	./mac/.macos
