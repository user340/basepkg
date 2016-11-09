# basepkg
NetBSD system packages
## How to use
### 1. make binary sets
``# cd /usr/src``  
``# ./build.sh -O ../obj -T ../tools sets``  
### 2. install pkg_install
``# cd /usr/pkgsrc/pkgtools/pkg_install``  
``# make install clean clean-depends``  
### 3. run basepkg utility
``# ./extract.sh``  
``# ./runit.sh``  
### 4. install any packages
``# cd packages``  
``# pkg_add base comp ...``
