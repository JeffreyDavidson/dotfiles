# Jeffrey's Dotfiles

This repository serves as my way to help me setup and maintain my Mac. It takes the effort out of installing everything manually. Everything needed to install my preferred setup of macOS is detailed in this readme. Feel free to explore, learn and copy parts for your own dotfiles. Enjoy! 😄

## A Fresh macOS Setup

These instructions are for when you've already set up your dotfiles. If you want to get started with your own dotfiles you can [find instructions below](#Your-Own-Dotfiles).

### Before you re-install

First, go through the checklist below to make sure you didn't forget anything before you wipe your hard drive.

* Did you commit and push any changes/branches to your git repositories?
* Did you remember to save all important documents from non-iCloud directories?
* Did you save all of your work from apps which aren't synced through iCloud?
* Did you remember to export important data from your local database?
* Did you update mackup to the latest version and ran mackup backup?

### Installing macOS cleanly

After going to our checklist above and making sure you backed everything up, we're going to cleanly install macOS with the latest release. Follow [this](https://www.imore.com/how-do-clean-install-macos) article to cleanly install the latest macOS version.

### Setting up your Mac

If you did all of the above you may now follow these install instructions to setup a new Mac.

Update macOS to the latest version with the App Store
1. Install Xcode from the App Store, open it and accept the license agreement
2. Install macOS Command Line Tools by running `xcode-select --install`
3. [Generate a new public and private SSH key](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and add them to Github
4. Clone this repo to `~/.dotfiles`
5. Install [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh#getting-started)
6. Run `install.sh` to start the installation
7. After mackup is synced with your cloud storage, restore preferences by running `mackup restore`
8. Restart your computer to finalize the process

Your Mac is now ready to use!

> Note: you can use a different location than ~/.dotfiles if you want. Just make sure you also update the reference in the `.zshrc` file.

## Your Own Dotfiles

**Please note that the instructions below assume you already have set up Oh My Zsh so make sure to first [install Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh#getting-started) before you continue.**

If you want to start with your own dotfiles from this setup, it's pretty easy to do so. First of all you'll need to fork this repo. After that you can tweak it the way you want.

Go through the `.macos` file and adjust the settings to your liking. You can find much more settings at [the original script by Mathias Bynens](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) and [Kevin Suttle's macOS Defaults project](https://github.com/kevinSuttle/MacOS-Defaults).

Check out the `Brewfile` file and adjust the apps you want to install for your machine. Use [their search page](https://formulae.brew.sh) to check if the app you want to install is available.

Check out the [aliases.zsh](https://github.com/jeffreydavidson/dotfiles/blob/master/aliases.zsh) file and add your own aliases. If you need to tweak your `$PATH` check out the [path.zsh](https://github.com/jeffreydavidson/dotfiles/blob/master/path.zsh) file. These files get loaded in because the `$ZSH_CUSTOM` setting points to the `.dotfiles` directory. You can adjust the [.zshrc](https://github.com/jeffreydavidson/dotfiles/blob/master/.zshrc) file to your liking to tweak your Oh My Zsh setup. More info about how to customize Oh My Zsh can be found [here](https://github.com/ohmyzsh/ohmyzsh/wiki/Customization).

When installing these dotfiles for the first time you'll need to backup all of your settings with Mackup. Install Mackup and backup your settings with the commands below. Your settings will be synced to iCloud so you can use them to sync between computers and reinstall them when reinstalling your Mac. If you want to save your settings to a different directory or different storage than iCloud, [checkout the documentation](https://github.com/lra/mackup/blob/master/doc/README.md#storage). Also make sure your `.zshrc` file is symlinked from your dotfiles repo to your home directory.

```
brew install mackup
mackup backup
```

You can tweak the shell theme, the Oh My Zsh settings and much more. Go through the files in this repo and tweak everything to your liking.

Enjoy your own Dotfiles!