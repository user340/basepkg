# basepkg developer tools

## Required

- AWK
- Python 3.7 (We recommend that using `venv` for developer tools)
- NetBSD source tree

## Installation

```
$ python setup.py install
```

## sync_valid_MACHINE_ARCH

It Takes data that listing all valid MACHINE/MACHINE_PARCH pairs from `build.sh`.

## mark-obsolete

Replace "-unknown-" to "XXX-obsolete". Here, XXX is category.

```
$ mark-obsolete xbase md.amd64
```

## show_pkgname

Show package names in given file.

```
$ show_pkgname xbase/md.amd64
xbase-i810-lib
xbase-libdrm-amdgpu
xbase-libdrm-intel
xbase-libdrm-nouveau
xbase-libvdpau-lib
xbase-openchrome-lib
xbase-xvmc-lib
```
