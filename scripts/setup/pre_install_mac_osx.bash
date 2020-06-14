#!/usr/bin/env bash

# install the following packages or similar using homebrew
# openjdk-8-jdk unzip libz-dev git build-essential m4 libpcre3-dev gcc-8 g++-8 cmake python-dev oracle-java8-installer maven


# Starting installation of needed dependancies and software
echo "Homebrew is needed, please make sure it is installed"
brew update

# install mac commandline tools
echo "Instalilng mac commandline tools (may ask for password)"
xcode-select --install

echo "Installing correct gcc version 9.0"
brew install gcc@9 pcre cmake maven
brew install java11
ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
echo "export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home/" >> /etc/bashrc

echo "Installing Python-pip"
curl 'https://bootstrap.pypa.io/get-pip.py' > get-pip.py && sudo python get-pip.py
pip install --upgrade pip