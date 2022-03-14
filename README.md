# Extensible Dependency Grammar (XDG) Development Kit (XDK)
This is an IDE for Extensible Dependency Grammar (XDG), a modular grammar framework developed at Saarland University (Saarbrücken/Germany) in the late 1990s and early 2000s.

As the main person behind it (along with [Denys Duchier](https://www.univ-orleans.fr/lifo/Membres/duchier/index_en.html) who started it all and created the entire foundation) and numerous others, I think XDG was far ahead of its time and actually still is in 2022, which is why I decided to put it on GitHub. Have fun :-)

# Installation
Since the XDK is based on the v1 version of [Mozart-Oz](http://mozart2.org/), which is 32bit-only, the easiest way to run XDK is using [Wine](https://www.winehq.org/).

1. Install [Wine](https://www.winehq.org/).
2. Install the latest v1 version of Mozart-Oz from [here](https://sourceforge.net/projects/mozart-oz/files/v1/1.4.0-2008-07-04-windows/) on Wine by running the installer `wine Mozart-1.4.0.20080704.exe`.
3. Clone the XDK directory, `cd` into it, and call the script `make_wine.sh` - this copies the native functors to their right place and then calls `ozmake` to build XDK.

When the build has completed successfully, just call `wine xdk` to run the XDK :-)

If you also like to use the Mozart-Oz IDE based on emacs, just install an older version of emacs on Wine (e.g. 22.3 [from here](https://ftp.gnu.org/gnu/emacs/windows/emacs-22/), I haven't tested newer versions)) and set the environment variable `OZEMACS` to where you have installed it. That is, use `wine regedit` to create a new "String Value" under `HKEY_CURRENT_USER/Environment` and set it to e.g. `C:\Program Files (x86)\emacs-22.3\bin\emacs.exe`. Then you can get into the Mozart-Oz IDE by simply typing `wine oz`.
