uthash-rpm
==========

A simple Makefile to package the [uthash](https://github.com/troydhanson/uthash)
header collection as RPM package. Of course, you'll need to have rpmbuild
installed to create the package. After this
```
git clone https://github.com/schlagert/uthash-rpm.git
make
```
you should find your RPM package in the current working directory.
```
$ ls
Makefile  README.md  uthash-1.9.8-1.el6.i386.rpm
```
