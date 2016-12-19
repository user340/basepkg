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

### 2. Extract NetBSD Binary Sets to Working Directory
Second, Extract binary sets to working directory using basepkg.sh script.  
```# cd /path/to/basepkg```  
```# ./basepkg.sh extract```

### 3. Make Packages
Third, Run basepkg.sh script with options.  
```# ./basepkg.sh dir```  
```# ./basepkg.sh list```  
```# ./basepkg.sh pkg```  
Packages are created under the basepkg/packages directory.

### 4. How to Install Packages?
Example, installing base/base-sys-root.  
```# pkg_add packages/base/base-sys-root```
