# License
Copyright (c) 2016 Yuuki Enomoto  
All rights reserved.  
  
Redistribution and use in source and binary forms, with or without  
modification, are permitted provided that the following conditions are met:  
  
* Redistributions of source code must retain the above copyright notice, this  
  list of conditions and the following disclaimer.  
  
* Redistributions in binary form must reproduce the above copyright notice,  
  this list of conditions and the following disclaimer in the documentation  
  and/or other materials provided with the distribution.  
  
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE  
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE  
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR  
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER  
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,  
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
# What is this
NetBSD packaged base system 
Testing on virtual machines or dedicated testing machines is strongly encouraged.
## How to use
### 1. Build NetBSD
In this procedure, NetBSD source sets is in /usr/src, NetBSD build-tools is in /usr/tools,  
NetBSD compiled objects is in /usr/obj .  
And NetBSD Version is 7.0.2, machine is amd64, machine archtecture is x86\_64.  
  
First, Download NetBSD Source Sets and Extract to /usr/src.  
```# cd /```  
```# ftp ftp://ftp.netbsd.org/pub/NetBSD/NetBSD-7.0/source/```  
```ftp> mget *.tgz```  
```ftp> bye```  
```# ls | grep 'tgz$' | xargs -n 1 tar zxf```  
```# ls | grep 'tgz$' | xargs rm```  
```# mkdir /usr/obj /usr/tools ; cd /usr/src```  
```# ./build.sh -O ../obj -T ../tools tools```  
```# ./build.sh -O ../obj -T ../tools distribution```  
```# ./build.sh -O ../obj -T ../tools sets```

### 2. Install pkgtools/pkg_install From pkgsrc or pkgin
```# cd /usr```  
```# ftp ftp://ftp.netbsd.org/pub/pkgsrc/stable/pkgsrc.tar.gz```  
```# tar zxf pkgsrc.tar.gz && rm pkgsrc.tar.gz```  
```# cd pkgsrc/pkgtools/pkg_install```  
```# make install clean clean-depends```

or

```# pkgin install pkg_install```

### 3. Extract NetBSD Binary Sets to Working Directory
Extract binary sets to working directory using basepkg.sh script.  
```# cd /path/to/basepkg```  
```# ./basepkg.sh extract```

### 4. Make Packages
Run basepkg.sh script with options.  
```# ./basepkg.sh dir```  
```# ./basepkg.sh list```  
```# ./basepkg.sh pkg```  
Packages are created under the basepkg/packages directory.

### 5. How to Install Package?
Example, installing base/base-sys-root.  
```# pkg_add packages/base/base-sys-root```  
But, base-sys-root package's information stored in /v 
ar/db/pkg.  
Then I recommend use ```-K /var/db/basepkg``` option  
for discriminate between pkgsrc's package and basepkg's package.  
```# pkg_add -K /var/db/basepkg packages/base/base-sys-root```  
Or, use utils/bpkg_add script instead of pkg_add.  
```# sh utils/bpkg_add packages/base/base-sys-root```

### 6. Can I install the package using pkgin?
Yes, you can.  
Example, "games" categorized package install to system using pkgin,  
you have to make pkg_summary.gz.  
```# cd packages/games```  
```# pkg_info -X * > pkg_summary```  
```# gzip pkg_summary```  
Then, edit /usr/pkg/etc/pkgin/repositories.conf and update pkgin.  
```# echo "file:///path/to/basepkg/packages/games" >> /usr/pkg/etc/pkgin/repositories.conf```  
```# pkgin update```  
Let's install the package through pkgin :-)  
```# pkgin in games-games-bin```
