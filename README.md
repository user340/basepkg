# License
Copyright (c) 2016,2017 Yuuki Enomoto

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# What is "basepkg"

## How to use

### 1. Build the NetBSD distribution

In this procedure, NetBSD source sets is in /usr/src, NetBSD build-tools is in /usr/tools, NetBSD compiled objects is in /usr/obj, and NetBSD Version is 7.1, machine is amd64, machine archtecture is x86\_64.

First, Download NetBSD Source Sets and Extract to /usr/src.

    # cd /
    # ftp ftp://ftp.netbsd.org/pub/NetBSD/NetBSD-7.1/source/
    ftp> mget *.tgz
    ftp> bye
    # ls | grep 'tgz$' | xargs -n 1 tar zxf
    # ls | grep 'tgz$' | xargs rm
    # mkdir /usr/obj /usr/tools ; cd /usr/src
    # ./build.sh -O ../obj -T ../tools tools
    # ./build.sh -O ../obj -T ../tools distribution

### 2. Install pkgtools/pkg\_install

    # cd /usr
    # ftp ftp://ftp.netbsd.org/pub/pkgsrc/stable/pkgsrc.tar.gz
    # tar zxf pkgsrc.tar.gz && rm pkgsrc.tar.gz
    # cd pkgsrc/pkgtools/pkg_install
    # make install clean clean-depen

or `# pkgin install pkg_install` for pkg\_* softwares.

### 3. Run basepkg.sh for packages

Run basepkg.sh script with **pkg** option.

    # ./basepkg.sh --new --src=/usr/src --obj=/usr/obj pkg
    # ./basepkg.sh --new --src=/usr/src --obj=/usr/obj kern-pkg

Packages are created under the packages/<release-version>/<machine> directory.

### 4. How to install package?

    # pkg_add -K /var/db/basepkg games-games-bin-7.1.tgz

But if you want to install "etc-*" packages to system, use with **-p** option for existing files.

    # pkg_add -K /var/db/basepkg -p tmp/basepkg/ etc-sys-rc-7.1.tgz

Because, *pkg\_add* will overwrite existing files under /etc.

### 5. pkgsrc-wip

Basepkg imported to pkgsrc-wip. You can install basepkg to your system through pkgsrc-wip.

    # cd /usr/pkgsrc/wip/basepkg
    # make install clean

"basepkg.sh" and README are installed to /usr/pkg/share/basepkg.
