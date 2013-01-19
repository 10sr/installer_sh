installer.sh
============

Write your own installation script!


What is installer.sh for?
-------------------------

I'm tired of downloading tarball and running commands like `./configure`,
`make`, `make install` ... many many times. Definitely developers know where to
download the tarball from, how to build the program and how to install. They
should write the script to automate installation.

installer.sh makes it easy to write scripts automating installation. You can
automate installion of your great programs or some other useful programs by
define a few variables and a function in installer.sh.

installer.sh is strongly inspired by [ArchLinux](http://www.archlinux.org/)'s
makepkg and [PKGBUILD](https://wiki.archlinux.org/index.php/Creating_Packages).


Things installer.sh does not do
-------------------------------

installer.sh is not a package manager. It does not:

* manage installed packages
* record installed files (and uninstall packages by removing these files)
* update packages automatically

And of course you should use package manager if the software is provided by the
package manager you are using. This script is for softwares which is not so
popular, or not updated to newer version on your system.


Install
-------

installer.sh is not intended to install. Use this script as a template and write
as you need!


Defining a package
------------------

Define some variables and functions.

### $pkgname

Name of package.

### $source (if needed)

Newline separated list of urls to download archives from.

Each line is just the url to download archives or can be like
`package-0.1.tar.gz::http://example.com/package.tar.gz`. In this form, you can
change the name of downloaded archive.

Each Downloaded file is extracted immediately in $srcdir If it it a archive. If
the url looks like a git repository, clone it.

### $pkgver (optional)

Version string.

### $pkgdesc (optional)

Short description.

### $url (optional)

Url of the software.

### install()

Function to install package.

When functions are called, $startdir and $srcdir were set. $startdir is the
working directory when install.sh was executed and $srcdir is directory where
downloaded archive files are extracted. Usually you can use a command like
`cd $srcdir/$pkgname-$pkgver` to go into the directory files were extracted.

### uninstall() (optional)

Function to uninstall the package, if possible.

## Execute installer.sh

To install the package, run:

    $ ./installer.sh install

Only download archive listed in $source and extract them by:

    $ ./installer.sh fetch

## License

All code licensed under CC0: <http://creativecommons.org/publicdomain/zero/1.0/>
