installer.sh
============

General porpose installation script.


What installer.sh is for?
-------------------------

I'm tired of downloading tarball and run commands like `./configure`, `make`,
`make install` ... many many times. Definitely developers know where to download
the tarball from, how to build the program and how to install. They should write
the script to automate installation.

This script is intend to make it easy to write automation scripts. You can
automate installing your great programs or some other useful programs by add
some variables and write a function in installer.sh.


Things installer.sh does not do
-------------------------------

This script is not a package manager. It does not:

* manage installed packages
* uninstall packages
* update packages automatically


Install
-------

This script is not intended to install. Use this script as template and write
as you need!


Usage
-----

Download this script and define some variable and functions.

### $pkgname

Name of package.

### $source (if needed)

Newline separated list of urls to download the archive from.

Each line is just the url to download or can be like:

    package-0.1.tar.gz::http://example.com/package.tar.gz

In this form, you can change the name of downloaded archive.

Downloaded files are extracted immediately in $srcdir. If the url looks like a
git repository, clone it.

### $pkgver (optional)

Version string of package.

### $pkgdesc (optional)

Short description of package.

### $url (optional)

Url of the package.

### install()

Function to install package.

When functions are called, $startdir and $srcdir are set. $startdir is the
working directory when execute install.sh and $srcdir is directory where
downloaded archive files are extracted. Usually you can use
`cd $srcdir/$pkgname-$pkgver` to change into the directory files are extracted.

### uninstall() (optional)

Function to uninstall package, if possible.
