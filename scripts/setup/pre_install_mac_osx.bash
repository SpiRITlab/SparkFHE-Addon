#!/usr/bin/env bash

# install the following packages or similar using homebrew
# openjdk-8-jdk unzip libz-dev git build-essential m4 libpcre3-dev gcc-8 g++-8 cmake python-dev oracle-java8-installer maven


# Starting installation of needed dependancies and software
echo "Homebrew is needed, please make sure it is installed"
brew update

# install mac commandline tools
echo "Instalilng mac commandline tools (may ask for password)"
xcode-select --install

# The current version of gcc that homebrew installs is 8.2.0
echo "Installing correct gcc version (8.2.0)"
brew install gcc@8 pcre cmake maven
brew tap caskroom/versions
brew cask install java8