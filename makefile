download:
	wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -O vscode.tar.gz

unpack:
	rm -Rf VSCode-linux-x64
	tar xf vscode.tar.gz
	mkdir VSCode-linux-x64/data

run:
	VSCode-linux-x64/code

install-extensions:
	for extension in `cat extensions.txt` ; do \
		echo $${extension} ; \
		VSCode-linux-x64/bin/code --install-extension $${extension} ; \
	done

package:
	zip -r Portable-VSCode-linux-x64.zip VSCode-linux-x64
	
all: download unpack install-extensions package