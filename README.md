[![Build Status](https://travis-ci.org/10sr/installer_sh.svg)](https://travis-ci.org/10sr/installer_sh)



installer.sh
============

Write your own installation script!



What is installer.sh for?
-------------------------

I'm tired of downloading tarballs, extracting them and running commands like
`./configure`, `make`, `make install` ... many many times. Definitely developers
know where to download the tarballs from, how to build and how to install the
Softwares. They should write the script to automate installation.

installer.sh makes it easy to write scripts automating installation. You can
automate installion of your great softwares or some other useful softwares by
defining a few variables and a function in installer.sh.

installer.sh is strongly inspired by [ArchLinux](http://www.archlinux.org/)'s
makepkg and [PKGBUILD](https://wiki.archlinux.org/index.php/Creating_Packages).



Things installer.sh does not do
-------------------------------

installer.sh is not a package manager. It does not:

* manage installed packages
* resolve dependencies
* record installed files (and uninstall packages by removing these files)
* update packages automatically

Users who want to install softwares should not use installer.sh when the
softwares are provided by package managers. This script is for softwares which
are not so popular, or not updated to newer version on some systems.



Install
-------

installer.sh is not intended to install. Use this script as a template and write
commands as you need!



Define a package
----------------

Define some variables and functions.


### $pkgname

Name of package.


### $source (if needed)

Newline separated list of urls of archives. Archive listed here will be
downloaded and extracted automatically. If the archives already exist, do
not download them twice.

Each line is just the url to download archives or can be like
`$pkgname-$pkgver.tar.gz::http://example.com/file.tar.gz`. In this form, you can
change the name of downloaded archive.

Each Downloaded file is extracted immediately in `$srcdir` If it has a archive
 suffix.


### $pkgver (optional)

Version of the software.


### $pkgdesc (optional)

Short description.


### $url (optional)

Url of the software.


### main()

Function called when installing package.

Before `main()` is called, archives listed in `$sources` are downloaded and
extracted, and `$startdir` and `$srcdir` are set. `$startdir` is the working
directory when install.sh was executed and `$srcdir` is directory where
downloaded archive files are extracted. Usually you can use a command like
`cd $srcdir/$pkgname-$pkgver` to go into the directory the files were
extracted.


### help_main() (optional)

Additional help descripting options of `main()`. If defined, this function
is called when subcommand `help` is used.


### Reserved variable and function names

All names start with double underscores (like `__val`) is all reserved for the
internal porpose, whareas you can freely use names with one underscore (like
`_val`).


Use installer.sh
----------------

To install the package, run:

    $ ./installer.sh install

Subcommand `install` fetches files listed in `$sources`, extracts them if they
are archive files, and then calls `main()` with given options.

To only download archive listed in $source and extract them, run:

    $ ./installer.sh fetch

This command is especially useful when you are writing `main()` or you want
to issue some commands before calling `main()`.

`$ ./installer.sh help` for additional help.


### Note: fetching and extracting

Fetching a file and extracting are done when and only when the file does not
exist. If a file is already exists at the path the file to be fetched would
be placed, neither fetching nor extracting the file are done. So if you remove
only files generated by extracting, things do not work well because files
are not extracted since the archive file already exists.



License
-------

All code licensed under CC0: <http://creativecommons.org/publicdomain/zero/1.0/>
