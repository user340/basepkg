```
Copyright (c) 2016-2019 Yuuki Enomoto
Copyright (c) 2001-2019 The NetBSD Foundation, Inc.
All rights reserved. 
 
Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met: 
 
* Redistributions of source code must retain the above copyright notice, 
  this list of conditions and the following disclaimer.
 
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution. 
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.
```

# basepkg -- NetBSD system packages

basepkg is developing in GitHub (https://github.com/user340/basepkg).

Please contact to Yuuki Enomoto <uki@e-yuuki.org> for bug-report, question, discussion, donation of patches and others. Or you can use GitHub issues and pull-requests for these things.

1. [Usage](#usage)
    1. [Build the NetBSD distribution](#build-the-netbsd-distribution)
    2. [Install pkgtools/pkg\_install](#install-pkgtools/pkg_install)
    3. [Run basepkg.sh](#run-basepkg.sh)
    4. [How to install package](#how-to-install-pakcage)
    5. [pkgsrc-wip](#pkgsrc-wip)
2. [Background](#background)
    1. [syspkgs](#syspkgs)
    2. [Goal](#goal)
    3. [Presentations](#presentations)
3. [TODO](#todo)
4. [Contributors](#contributors)
5. [References](#references)

## 1. Usage

### 1.1. Build the NetBSD distribution

In this procedure, NetBSD source tree is in /usr/src, NetBSD build-tools is in /usr/tools, NetBSD compiled objects is in /usr/obj, NetBSD version is 7.1.2, machine is amd64, and machine archtecture is x86\_64.

This is description how to build NetBSD source tree. You can skip until section 1.2 if you understand it or done.

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

basepkg is tested by latest pkgtools/pkg\_install package[1]. We recommend that install it from pkgsrc for `basepkg.sh`.

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

Or you can use `pkgin` instead of pkgsrc. `pkgin` is a binary package manager for pkgsrc[2].

### 1.3. Run basepkg.sh

Run `basepkg.sh` with pkg and kern option.

```
# ./basepkg.sh pkg
# ./basepkg.sh kern
```

Packages are created under the packages/<release-version>/<machine>-<machine_arch> directory.

### 1.4. How to install package

Running `pkg\_add`. If you want to use other database than pkgsrc, you can use `-K /var/db/basepkg` option for separate database from pkgsrc.

```
# pkg\_add -K /var/db/basepkg games-games-bin-7.1.tgz
```

But "etc" categorized packages are exception. They are installed to /var/tmp/basepkg directory because the way keeps from overwrite existing files under the /etc. If you want to update the configuration files, please run etcupdate(8) manually.

```
# etcupdate -s /var/tmp/basepkg
```

### 1.5. pkgsrc-wip

basepkg is imported to pkgsrc-wip[3]. You can install basepkg to your system using pkgsrc-wip. But it supporting only latest version package.

```
# cd /usr/pkgsrc/wip/basepkg
# make install clean clean-depends
```

`basepkg.sh`, README and others are installed to /usr/pkg/basepkg. You can run `basepkg.sh` on /usr/pkg/basepkg directory. Packages are generated in /usr/pkg/basepkg/packages directory.

## 2. Background

### 2.1. syspkgs

NetBSD Wiki described, "syspkgs is the concept of using pkgsrc's pkg\_\* tools to maintain the base system. ... There has been a lot of work in this area already, but it has not yet been finalized."[4]

basepkg is intend to become a successor to syspkg. But basepkg is third-party software less like syspkg. It is an unofficial project of NetBSD.

### 2.2. Goal

We intend to efficient base system management by package on NetBSD. The way of update NetBSD base system are (1) build.sh and (2) download tarballs from FTP server. But the first way takes a long time to compile source tree. The second way is dengerous. 

A lot of Linux distributions (GNU/Linux) such as Debian and Red Hat Enterprise Linux (RHEL) has the very fast method for updating own system. These are "package" and "package manager". GNU/Linux and BSD Unix has different background about histories and the way of distribute. It is difficult to make simple comparisons for this reason. However "package" have been active for more than 20 years.  Management of whole/part of the system is very easy in GNU/Linux.

So we decided to use "package" for NetBSD base system. It is difficult as the example of syspkg illustrates. But it will provides benefit for NetBSD users.

### 2.3. Presentations

The presentations about basepkg are here.

[AsiaBSDCon 2018](http://www.netbsd.org/gallery/presentations/yuuki/2018_AsiaBSDCon/AsiaBSDCon2018-basepkg-paper.pdf )

[AsiaBSDCon 2017](http://www.netbsd.org/gallery/presentations/yuuki/2017_AsiaBSDCon/basepkg.pdf)

## 3. TODO

* Develop the auto update mechanism for "sets" (including comments, deps, lists, and others).
* Review +INSTALL and +DEINSTALL.
* Support pkgin(1).
* Provide package repository for pkgin(1).
* Support "source package" like as source RPM.
* Research "package" background from a viewpoint of Unix community, internet, and others.
* Improve documentation (including online manual, guidebook for develop, about basepkg architecture, ...).
* Import to pkgsrc from pkgsrc-wip.

## 4. Contributors

* Ken'ichi Fukamachi (www.fml.org)
* Cybertrust Japan Co., Ltd. (www.cybertrust.co.jp, www.miraclelinux.com)

## 5. References

[1] http://pkgsrc.se/pkgtools/pkg\_install 
[2] http://pkgin.net
[3] https://pkgsrc.org/wip
[4] https://wiki.netbsd.org/projects/project/syspkgs
