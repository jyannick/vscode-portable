#! /bin/bash

# USAGE

# Download and install latest version from github:
# ./install.sh

# Install (after building, if necessary) a local version:
# ./install.sh --local

# Download and install a version from a custom URL:
# ./install.sh --custom-url https://github.com/jyannick/vscode-portable/releases/download/0.2.0/Portable-VSCode-linux-x64.zip

# Download this script and execute it directly with arguments:
# curl https://github.com/jyannick/vscode-portable/releases/latest/download/install.sh | bash -s -- --custom-url https://github.com/jyannick/vscode-portable/releases/download/0.2.0/Portable-VSCode-linux-x64.zip


if [ $1 = "--local" ]; then
    echo "Using local archive"
    if [ ! -f ./Portable-VSCode-linux-x64.zip ]; then
        echo "Could not find local archive"
        make
    fi
    cp Portable-VSCode-linux-x64.zip /tmp/Portable-VSCode-linux-x64.zip
else
    if [ $1 = "--custom-url" ]; then
        echo "Using custom URL"
        wget $2 -O /tmp/Portable-VSCode-linux-x64.zip
    else
        wget https://github.com/jyannick/vscode-portable/releases/latest/download/Portable-VSCode-linux-x64.zip -O /tmp/Portable-VSCode-linux-x64.zip
    fi
fi

unzip /tmp/Portable-VSCode-linux-x64.zip -d /tmp/Portable-VSCode-linux-x64
rm /tmp/Portable-VSCode-linux-x64.zip

mkdir -p ~/.local/opt ~/.local/bin

if [ -d ~/.local/opt/Portable-VSCode-linux-x64 ]; then
    echo "Removing previous installation of Portable-VSCode"
    rm -Rf ~/.local/opt/Portable-VSCode-linux-x64
fi

echo "Installing new version"
mv /tmp/Portable-VSCode-linux-x64/Portable-VSCode-linux-x64 ~/.local/opt
rmdir /tmp/Portable-VSCode-linux-x64/
ln -s -f ~/.local/opt/Portable-VSCode-linux-x64/bin/code ~/.local/bin/code

if [ ! -d ~/.config/Portable-VSCode/User ]; then
    echo "Creating user config directory"
    mkdir -p ~/.config/Portable-VSCode/User
fi
rmdir ~/.local/opt/Portable-VSCode-linux-x64/data/user-data/User
ln -s ~/.config/Portable-VSCode/User ~/.local/opt/Portable-VSCode-linux-x64/data/user-data/ 

echo "Creating menu entry"
mkdir -p ~/.local/share/icons/hicolor/scalable/apps/
cp ~/.local/opt/Portable-VSCode-linux-x64/vscode.svg ~/.local/share/icons/hicolor/scalable/apps/Portable-VSCode.svg
desktop-file-install --dir=$HOME/.local/share/applications ~/.local/opt/Portable-VSCode-linux-x64/Portable-VSCode.desktop 
update-desktop-database ~/.local/share/applications

echo "Done. You can start Portable-VSCode by running ~/.local/bin/code"
echo "You can also use the desktop menu entry. You might need to log out before it shows up."