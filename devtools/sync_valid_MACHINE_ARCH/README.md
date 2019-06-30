# sync_valid_MACHINE_ARCH

## Required

- Python 3.7
- 

## Install

We recommend that using `venv` or `virtualenv`.

```
$ make install
```

## Usage

```
$ sync_valid_MACHINE_ARCH.py -h
usage: sync_valid_MACHINE_ARCH.py [-h] path

Sync valid_MACHINE_ARCH list for basepkg.sh

positional arguments:
  path        Specify path to build.sh of NetBSD source tree
  
  optional arguments:
    -h, --help  show this help message and exit
```

### Example

```
$ sync_valid_MACHINE_ARCH /usr/src/build.sh
```
