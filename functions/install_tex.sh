# Install Tex (basictex)
# https://www.ctan.org
# This will also attempt to install recommended packages.

# Attempt to install basictex automatically.
# This contains tlmgr, which manages CTAN packages.
command -v tlmgr >/dev/null 2>&1 || {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo "Installing basictex cask"
        command -v brew >/dev/null 2>&1 || {
            echo >&2 "brew missing"
            return 1
        }
        brew cask install basictex 
    fi
}

# Check for tlmgr again and error if not installed.
command -v tlmgr >/dev/null 2>&1 || {
    echo >&2 "tlmgr missing"
    return 1
}

# Now run the updater and install recommended packages.
sudo tlmgr update --self
packages=(collection-fontsrecommended  # priority
          collection-latexrecommended  # priority
          bera  # beramono
          caption
          changepage
          csvsimple
          enumitem
          etoolbox
          fancyhdr
          footmisc
          framed
          geometry
          hyperref
          inconsolata
          marginfix
          mathtools
          natbib
          nowidow
          parnotes
          parskip
          placeins
          preprint  # authblk
          sectsty
          soul
          titlesec
          titling
          xstring)
for package in ${packages[@]}; do
    sudo tlmgr install "$package"
done
