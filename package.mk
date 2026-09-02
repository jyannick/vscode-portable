.DEFAULT_GOAL := all

clean:
	rm -Rf Portable-VSCode-linux-x64
	rm -Rf visual-studio-code-icons
	rm -f vscode.tar.gz
	rm -f visual-studio-code-icons.zip
	rm -f manifest.md
	rm -f Portable-VSCode-linux-x64.zip

download:
	wget --no-verbose "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -O vscode.tar.gz
	wget --no-verbose "https://code.visualstudio.com/assets/branding/visual-studio-code-icons.zip" -O visual-studio-code-icons.zip

unpack:
	rm -Rf Portable-VSCode-linux-x64
	tar xf vscode.tar.gz
	mv VSCode-linux-x64 Portable-VSCode-linux-x64
	mkdir Portable-VSCode-linux-x64/data
	rm -Rf visual-studio-code-icons
	unzip visual-studio-code-icons.zip

run:
	Portable-VSCode-linux-x64/bin/code

install-extensions:
	@ids=`tr -d '\r' < extensions.txt | grep -v '^#' | grep -v '^[[:space:]]*$$' | sed 's|^|--install-extension |g' | tr '\n' ' '`; \
	for attempt in 1 2 3; do \
		Portable-VSCode-linux-x64/bin/code $$ids && exit 0; \
		echo "install-extensions attempt $$attempt failed (installing ~70 extensions in one call can trip transient marketplace/CDN 503s under load), retrying in 15s..." >&2; \
		sleep 15; \
	done; \
	echo "install-extensions failed after 3 attempts" >&2; \
	exit 1
    # tr -d '\r' guards against CRLF line endings (e.g. from a checkout with
    # core.autocrlf=true): a trailing \r left in an id makes the marketplace
    # report it as "not found". .gitattributes pins extensions.txt to LF, but
    # this keeps the build correct regardless of local git config.
    # grep -v '^#' skips comment lines; the second grep skips blank lines,
    # which are used as visual separators between groups and would otherwise
    # produce a bogus "--install-extension" flag with an empty value.
    # Retrying the whole call is safe: already-installed extensions are
    # skipped, so a retry only needs to fill in whatever failed.

manifest:
	echo "# Portable VSCode" > manifest.md
	echo "https://github.com/jyannick/vscode-portable\n" >> manifest.md
	( git describe --tags || git show --oneline -s ) >> manifest.md
	echo "## VSCode version" >> manifest.md
	Portable-VSCode-linux-x64/bin/code -v | sed 's|^|* |g' >> manifest.md
	echo "## Extensions" >> manifest.md
	Portable-VSCode-linux-x64/bin/code --list-extensions --show-versions | sed 's|^|* |g' >> manifest.md
	cp manifest.md Portable-VSCode-linux-x64/portable-vscode-manifest.md

package:
	cp visual-studio-code-icons/vscode.svg Portable-VSCode-linux-x64
	zip --filesync -r Portable-VSCode-linux-x64.zip Portable-VSCode-linux-x64

all_but_package: download unpack install-extensions manifest

all: all_but_package package
