#!/usr/bin/env python

import argparse
import os
from lib import common
from pathlib import Path, PosixPath


def getargs() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'file', type=str,
        help='Target file which include filename, package name and options.'
    )
    return parser.parse_args()


def get_all_lists(listsdir: PosixPath) -> str:
    """
    [generator]
    Get all lists from xbase, xcomp, xetc, xfont, xserver directories
    that under the given directory.

    Arguments:
        - listsdir: PosixPath -- Path to listsdir. for example,
                                 Path('/usr/src/distrib/sets/lists')
    Return
        - str

    Return Example:
        /usr/src/distrib/sets/lists/xbase/md.amd64
        /usr/src/distrib/sets/lists/xbase/md.evbarm
        /usr/src/distrib/sets/lists/xbase/md.i386
        /usr/src/distrib/sets/lists/xbase/mi
        /usr/src/distrib/sets/lists/xbase/shl.mi
        /usr/src/distrib/sets/lists/xcomp/md.acorn32
        ...
    """
    targetdirs = ['xbase', 'xcomp', 'xetc', 'xfont', 'xserver']
    for d in targetdirs:
        for root, dirs, files in os.walk(listsdir / d):
            if 'CVS' in dirs:
                dirs.remove('CVS')
            for f in files:
                yield os.path.join(root, f)


def collect_filename_and_package_pair(listsdir: PosixPath) -> dict:
    """
    Collect pair of filename and package name from lists under the given
    listsdir. Obsolete or unknown packages are ignored.

    Arguments:
        - listsdir: PosixPath -- Path to listsdir. for example,
                                 Path('/usr/src/distrib/sets/lists')

    Return:
        - dict

    Return Example:
        {
            "./usr/X11R7/bin/Xmark": "xbase-x11perf-bin",
            "./usr/X11R7/bin/appres": "xbase-appres-bin",
            ...
        }
    """
    ret = dict()

    for listfile in get_all_lists(listsdir):
        with open(listfile, mode='r', encoding='utf-8') as f:
            for line in f:
                if line.startswith('#') or 'obsolete' in line \
                                        or '-unknown-' in line \
                                        or '-unknown' in line:
                    continue
                filename, pkgname = [x for x in line.split('\t') if x][0:2]
                if filename not in ret:
                    ret[filename] = pkgname

    return ret


def give_package_names(path: PosixPath, file_and_pkg: dict) -> None:
    """
    Replace "-unknown-" to debug package name "*-debug" or "*-debuglib" in
    given file.

    Arguments:
        - path: PosixPath -- File path which is target
        - file_and_pkg: dict -- Pair of filename and package name

    Return:
        - None

    Work Example:
        ./usr/X11R7/lib/libICE_g.a -unknown- xorg,debuglib

        to

        ./usr/X11R7/lib/libICE_g.a xdebug-libICE-debuglib xorg,debuglib

        because ./usr/X11R7/lib/libICE_g.a is included in xbase-libICE-lib.
    """
    if not path.exists():
        raise FileNotFoundError

    tempfile = Path(path.as_posix() + '.tmp')
    if tempfile.exists():
        tempfile.unlink()

    with tempfile.open(mode='w', encoding='utf-8') as tmp:
        with path.open(mode='r', encoding='utf-8') as f:
            for line in f:
                if line.startswith('#') or 'obsolete' in line:
                    tmp.write(line)
                    continue

                filename = line.split('\t')[0]

                debuglib = False
                debug = False

                if filename.endswith('_g.a'):
                    # debuglib package
                    searching = filename.replace('_g.a', '.so')
                    debuglib = True
                elif filename.endswith('.debug'):
                    # debug package
                    searching = filename.replace('.debug', '') \
                                        .replace('/usr/libdata/debug', '')
                    debug = True
                else:
                    searching = filename
                del filename

                result = file_and_pkg.get(searching, '-unknown-')
                del searching

                # XXX: bad variable name "x"
                x = result.split('-')
                x[0] = 'xdebug'
                if debuglib:
                    x[-1] = 'debuglib'
                    debug_package_name = '-'.join(x)
                elif debug:
                    x[-1] = 'debug'
                    debug_package_name = '-'.join(x)
                else:
                    debug_package_name = result
                del x
                del result

                tmp.write(line.replace('-unknown-', debug_package_name))

    tempfile.replace(path)


def main():
    args = getargs()
    target = Path(args.file)
    if not target.exists():
        raise FileNotFoundError
    del args

    listsdir = Path(common.NetBSD_src_dir).expanduser() / 'distrib' \
                                                        / 'sets' \
                                                        / 'lists'
    file_and_pkg = collect_filename_and_package_pair(listsdir)
    give_package_names(target, file_and_pkg)


if __name__ == '__main__':
    main()
