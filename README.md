# basepkg

NetBSD system packages like as PkgBase (FreeBSD).

Please contact to Yuuki Enomoto (uki@e-yuuki.org) 
for bug-report, question, discussion and others.

## How to use

### 1. Build the NetBSD distribution

In this procedure, 
NetBSD source sets is in **/usr/src**, 
NetBSD build-tools is in **/usr/tools**, 
NetBSD compiled objects is in **/usr/obj**, 
and NetBSD Version is 7.1.2, machine is amd64, machine archtecture is x86\_64.

First, download NetBSD source sets and extract to /usr/src.
Then, build it.

    # cd /
    # ftp ftp://ftp.netbsd.org/pub/NetBSD/NetBSD-7.1.2/source/
    ftp> mget *.tgz
    ftp> bye
    # ls | grep 'tgz$' | xargs -n 1 tar zxf
    # ls | grep 'tgz$' | xargs rm
    # mkdir /usr/obj /usr/tools
    # cd /usr/src
    # ./build.sh -O ../obj -T ../tools -x -X ../xsrc tools
    # ./build.sh -O ../obj -T ../tools -x -X ../xsrc distribution

### 2. Install pkgtools/pkg\_install

    # cd /usr
    # ftp ftp://ftp.netbsd.org/pub/pkgsrc/stable/pkgsrc.tar.gz
    # tar zxf pkgsrc.tar.gz
    # rm pkgsrc.tar.gz
    # cd pkgsrc/pkgtools/pkg_install
    # make install clean clean-depen

or `pkgin install pkg_install` for **pkgtools/pkg\_install**.

### 3. Run basepkg.sh for packages

Run `basepkg.sh`(1) with `pkg` and `kern` option.

    # ./basepkg.sh pkg
    # ./basepkg.sh kern

Packages are created under the 
**packages/<release-version>/<machine>-<machine\_arch>** directory.

### 4. How to install package?

Running `pkg\_add`(1) with `-K /var/db/basepkg` for 
separate database from pkgsrc.

    # pkg_add -K /var/db/basepkg games-games-bin-7.1.tgz

Contents installed to the system.

But etc categorized packages are exception.
They are installed to **/var/tmp/basepkg** because the way keeps from 
overwrite existing files under the **/etc**.
If you want to update the configuration files, 
please run `etcupdate`(8) manually.

    # etcupdate -s /var/tmp/basepkg

### 5. pkgsrc-wip

Basepkg imported to pkgsrc-wip.
You can install basepkg to your system through pkgsrc-wip.
But it supporting only latest version package.

    # cd /usr/pkgsrc/wip/basepkg
    # make install clean clean-depends

`basepkg.sh`(1), README and others are installed to 
**/usr/pkg/basepkg** directory.

