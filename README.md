installer.sh
============

Write your own installation script!


What installer.sh is for?
-------------------------

I'm tired of downloading tarball and run commands like `./configure`, `make`,
`make install` ... many many times. Definitely developers know where to download
the tarball from, how to build the program and how to install. They should write
the script to automate installation.

installer.sh is intend to make it easy to write scripts automating installation.
You can automate installion of your great programs or some other useful programs
by define a few variables and a function in installer.sh.


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


Defining a package
------------------

Download this script and define some variables and functions.

### $pkgname

Name of package.

### $source (if needed)

Newline separated list of urls to download archives from.

Each line is just the url to download archives or can be like:

    package-0.1.tar.gz::http://example.com/package.tar.gz

In this form, you can change the name of downloaded archive.

Downloaded files are extracted immediately in $srcdir. If the url looks like a
git repository, clone it.

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
downloaded archive files are extracted. Usually you can use
`cd $srcdir/$pkgname-$pkgver` to change into the directory files were extracted.

### uninstall() (optional)

Function to uninstall package, if possible.

## Execute installer.sh

To install the package, run:

    $ ./installer.sh install

## License

Copyright 2013- 10sr  
Licensed under [GPLv3](http://www.gnu.org/licenses/gpl.html).
