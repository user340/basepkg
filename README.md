# basepkg -- NetBSD system packages

The basepkg project is unofficial experimental stage of [NetBSD syspkg project](https://wiki.netbsd.org/projects/project/syspkgs/).

This software is unstable. It may destroy your system. And we may make a large changes to the repository without previous notice. We recommend that use chroot environment or virtual machine for testing generated packages.

Please contact to Yuuki Enomoto <uki@e-yuuki.org> to bug-report, question, discussion, patche donation and others. Or you can use GitHub issues and pull-requests for these things.

<!-- vim-markdown-toc GFM -->

* [1. Usage](#1-usage)
    * [1.1. Build the NetBSD distribution](#11-build-the-netbsd-distribution)
    * [1.2. Install pkgtools/pkg\_install](#12-install-pkgtoolspkg_install)
    * [1.3. Run basepkg.sh](#13-run-basepkgsh)
    * [1.4. How to install package](#14-how-to-install-package)
    * [1.5. pkgsrc-wip](#15-pkgsrc-wip)
* [2. Background](#2-background)
    * [2.1. syspkgs](#21-syspkgs)
    * [2.2. Goal](#22-goal)
    * [2.3. Presentations](#23-presentations)
* [3. TODO](#3-todo)
* [4. Contributors](#4-contributors)
* [5. How to contribute](#5-how-to-contribute)
* [LICENSE](#license)

<!-- vim-markdown-toc -->

## 1. Usage

### 1.1. Build the NetBSD distribution

| Version | Machine Architecture | Architecture |
| :--     | :--                  | :--          |
| current | amd64                | x86\_64      |

| Directory  | Description              |
| :--        | :--                      |
| /usr/src   | NetBSD source tree       |
| /usr/xsrc  | NetBSD X11 source tree   |
| /usr/tools | Build tools              |
| /usr/obj   | Sets of compiled objects |

This is description how to build NetBSD source tree. You can skip until section [1.2. Install pkgtools/pkg\_install](#12-install-pkgtoolspkg_install) if you understand it or done.

Firstly, download NetBSD source sets from FTP server. Then extract it into /usr/src directory.

```
# ftp ftp://ftp.netbsd.org/pub/NetBSD/NetBSD-8.0/source/
...
ftp> mget .tgz
...
ftp> bye
# ls | grep 'tgz$' | xargs -n 1 -I % tar zxf -C /
# ls | grep 'tgz$' | xargs rm
```

Build it using `build.sh`.

```
# mkdir /usr/obj /usr/tools
# cd /usr/src
# ./build.sh -O ../obj -T ../tools -x -X ../xsrc tools
# ./build.sh -O ../obj -T ../tools -x -X ../xsrc distribution
```

### 1.2. Install pkgtools/pkg\_install

basepkg requires [pkgtools/pkg\_install](http://pkgsrc.se/pkgtools/pkg_install) package. We recommend that install the package from pkgsrc to run `basepkg.sh`.

This is way of get pkgsrc. Skip the section if you understand or done it.

```
# ftp ftp://ftp.netbsd.org/pub/pkgsrc/stable/pkgsrc.tar.gz
# tar zxf pkgsrc.tar.gz -C /usr
# rm pkgsrc.tar.gz
```

Run `make install clean clean-depends`.

```
# cd /usr/pkgsrc/pkgtools/pkg\_install
# make install clean clean-depends
```

Or you can use `pkgin` instead of pkgsrc. [pkgin](http://pkgin.net) is a binary package manager for pkgsrc.

### 1.3. Run basepkg.sh

Run `basepkg.sh` with pkg and kern option.

```
# ./basepkg.sh pkg
# ./basepkg.sh kern
```

Packages are created under the packages/<release-version>/<machine>-<machine_arch> directory.

### 1.4. How to install package

Running `pkg_add`. If you want to use other database than pkgsrc, you can use `-K /var/db/basepkg` option for separate database from pkgsrc.

```
# pkg\_add -K /var/db/basepkg games-games-bin-7.1.tgz
```

But "etc" categorized packages are exception. They are installed to /var/tmp/basepkg directory because the way keeps from overwrite existing files under the /etc. If you want to update the configuration files, please run etcupdate(8) manually.

```
# etcupdate -s /var/tmp/basepkg
```

### 1.5. pkgsrc-wip

basepkg was imported to [pkgsrc-wip](https://pkgsrc.org/wip). You can install basepkg to your system using pkgsrc-wip.

```
# cd /usr/pkgsrc/wip/basepkg
# make install clean clean-depends
```

`basepkg.sh`, README and others are installed to /usr/pkg/basepkg. You can run `basepkg.sh` on /usr/pkg/basepkg directory. Packages are generated in /usr/pkg/basepkg/packages directory.

## 2. Background

### 2.1. syspkgs

NetBSD Wiki described, "syspkgs is the concept of using pkgsrc's pkg\_\* tools to maintain the base system. ... There has been a lot of work in this area already, but it has not yet been finalized." in https://wiki.netbsd.org/projects/project/syspkgs

The basepkg is intend to become a successor to syspkg. But basepkg is third-party software less like syspkg. It is an unofficial project of NetBSD.

### 2.2. Goal

We intend to efficient base system management by package on NetBSD. The way of update NetBSD base system are (1) build.sh and (2) download tarballs from FTP server. But the first way takes a long time to compile source tree. The second way is dengerous. 

A lot of Linux distributions (GNU/Linux) such as Debian and Red Hat Enterprise Linux (RHEL) has the very fast method for updating own system. These are "package" and "package manager". GNU/Linux and BSD Unix has different background about histories and the way of distribute. It is difficult to make simple comparisons for this reason. However "package" have been active for more than 20 years.  Management of whole/part of the system is very easy in GNU/Linux.

So we decided to use "package" for NetBSD base system. It is difficult as the example of syspkg illustrates. But it will provides benefit for NetBSD users.

### 2.3. Presentations

The presentations about basepkg are here.

* [AsiaBSDCon 2018](http://www.netbsd.org/gallery/presentations/yuuki/2018_AsiaBSDCon/AsiaBSDCon2018-basepkg-paper.pdf )
* [AsiaBSDCon 2017](http://www.netbsd.org/gallery/presentations/yuuki/2017_AsiaBSDCon/basepkg.pdf)

## 3. TODO

* Develop the auto update mechanism for "sets" (including comments, deps, lists, and others).
* Review +INSTALL and +DEINSTALL.
* Support pkgin(1).
* Provide package repository for pkgin(1).
* Support "source package" like as source RPM.
* Research "package" background from a viewpoint of Unix community, internet, and others.
* Improve documentation (including online manual, guidebook for develop, about basepkg architecture, ...).
* Import to pkgsrc from pkgsrc-wip.
* See GitHub Issue

## 4. Contributors

* Ken'ichi Fukamachi (www.fml.org)
* Cybertrust Japan Co., Ltd. (www.cybertrust.co.jp, www.miraclelinux.com)

## 5. How to contribute

* __Be user of basepkg__
* Create issues on GitHub. Please make use of labels.
* Send bug-report/comments/request/... by e-mail.
* Fork the repository; hack it.
* Send pull-request.
* and more!

Please read [CONTRIBUTING.md](/CONTRIBUTING.md) for more details.

## LICENSE

BSD 2-Clause License. Refer [LICENSE](/LICENSE) for full text.
