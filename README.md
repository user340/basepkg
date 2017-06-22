# License
Copyright (c) 2016,2017 Yuuki Enomoto  
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
Make NetBSD's base system packages.

## How to use

### 1. Build NetBSD
In this procedure, NetBSD source sets is in /usr/src, NetBSD build-tools is in /usr/tools, NetBSD compiled objects is in /usr/obj. And NetBSD Version is 7.1, machine is amd64, machine archtecture is x86\_64.  
  
First, Download NetBSD Source Sets and Extract to /usr/src.  
```# cd /```  
```# ftp ftp://ftp.netbsd.org/pub/NetBSD/NetBSD-7.1/source/```  
```ftp> mget *.tgz```  
```ftp> bye```  
```# ls | grep 'tgz$' | xargs -n 1 tar zxf```  
```# ls | grep 'tgz$' | xargs rm```  
```# mkdir /usr/obj /usr/tools ; cd /usr/src```  
```# ./build.sh -O ../obj -T ../tools tools```  
```# ./build.sh -O ../obj -T ../tools distribution```  

### 2. Install pkgtools/pkg_install From pkgsrc or pkgin
```# cd /usr```  
```# ftp ftp://ftp.netbsd.org/pub/pkgsrc/stable/pkgsrc.tar.gz```  
```# tar zxf pkgsrc.tar.gz && rm pkgsrc.tar.gz```  
```# cd pkgsrc/pkgtools/pkg_install```  
```# make install clean clean-depends```

or

```# pkgin install pkg_install```

### 3. Make Packages
Run basepkg.sh script with __pkg__ option.  
```# ./basepkg.sh --new --src=/usr/src --obj=/usr/obj pkg```  
Packages are created under the packages/<release-version> directory.

### 4. How to Install Package?
Rub basepkg.sh script with __install__ option.  
```# ./basepkg.sh install packages/7.1/games-games-bin-7.1.tgz```  
In default, packages are installed under the /usr/pkg/basepkg/root directory.  
If you want to install to under the root, use __--system__ option.  
```# ./basepkg.sh --system install packages/7.1/games-games-bin-7.1.tgz```

### 6. Unable to Install Packages.
The following packages unable to install to the system.
- not exist base-termcap-share package, unable to resolution package's dependency.
	- base-groff-share
	- base-magic-share
	- base-reference-share
	- base-termcap-share
	- comp-c-share
	- comp-util-share
	- text-texinfo-share
- not exist base-libsaslc-examples package, unable to resolution package's dependency.
	- misc-libsaslc-examples
- Conflicting pacakge's contents.
	- base-atf-bin (base-kyua-bin)
		- usr/bin/atf-report
	- comp-c-debug (comp-c-lib)
		- usr/lib/libproc_p.a
	- comp-c-htmlman (comp-isns-htmlman)
		- usr/share/man/html3/isns.html
	- man-atf-htmlman (man-kyua-htmlman)
		- usr/share/man/html1/atf-report.html
	- man-atf-man (man-kyua-man)
		- usr/share/man/man1/atf-report.1
