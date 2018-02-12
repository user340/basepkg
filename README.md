# basepkg

NetBSD system packages.

## How to use

### 1. Build the NetBSD distribution

In this procedure, NetBSD source sets is in /usr/src, NetBSD build-tools is in /usr/tools, NetBSD compiled objects is in /usr/obj, and NetBSD Version is 7.1, machine is amd64, machine archtecture is x86\_64.

First, download NetBSD source sets and extract to /usr/src.

    # cd /
    # ftp ftp://ftp.netbsd.org/pub/NetBSD/NetBSD-7.1/source/
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

or `pkgin install pkg_install` for pkg\_* softwares.

### 3. Run basepkg.sh for packages

Run basepkg.sh script with **pkg** option.

    # ./basepkg.sh pkg
    # ./basepkg.sh kern

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

