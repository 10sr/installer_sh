installer.sh
============

Write your own installation script!


What is installer.sh for?
-------------------------

I'm tired of downloading tarballs, extracting them and running commands like
`./configure`, `make`, `make install` ... many many times. Definitely developers
know where to download the tarballs from, how to build the softwares and how to
install them. They should write the script to automate installation.

installer.sh makes it easy to write scripts automating installation. You can
automate installion of your great softwares or some other useful softwares by
defining a few variables and a function in installer.sh.

installer.sh is strongly inspired by [ArchLinux](http://www.archlinux.org/)'s
makepkg and [PKGBUILD](https://wiki.archlinux.org/index.php/Creating_Packages).


Things installer.sh does not do
-------------------------------

installer.sh is not a package manager. It does not:

* manage installed packages
* record installed files (and uninstall packages by removing these files)
* update packages automatically

Users who want to install softwares should not use installer.sh when the
softwares are provided by package managers. This script is for softwares which
are not so popular, or not updated to newer version on some systems.


Install
-------

installer.sh is not intended to install. Use this script as a template and write
commands as you need!


Defining a package
------------------

Define some variables and functions.

### $pkgname

Name of package.

### $source (if needed)

Newline separated list of urls of archives. Archive listed here will be
downloaded and extracted automatically. If the archives already exist, do
not download twice.

Each line is just the url to download archives or can be like
`$pkgname-$pkgver.tar.gz::http://example.com/file.tar.gz`. In this form, you can
change the name of downloaded archive.

Each Downloaded file is extracted immediately in $srcdir If it has a archive
 suffix. If the url looks like a git repository, clone it.

### $pkgver (optional)

Version of the software.

### $pkgdesc (optional)

Short description.

### $url (optional)

Url of the software.

### install()

Function to install package.

When functions are called, archives listed in $sources were downloaded and
extracted, and $startdir and $srcdir were set. $startdir is the working
directory when install.sh was executed and $srcdir is directory where
downloaded archive files are extracted. Usually you can use a command like
`cd $srcdir/$pkgname-$pkgver` to go into the directory files were extracted.

### uninstall() (optional)

Function to uninstall the package, if possible.

## Execute installer.sh

To install the package, run:

    $ ./installer.sh install

Only download archive listed in $source and extract them by:

    $ ./installer.sh fetch

This command is especially useful when you are writing `install()` or you want
to issue some commands before install.

## License

All code licensed under CC0: <http://creativecommons.org/publicdomain/zero/1.0/>
