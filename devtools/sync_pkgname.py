#!/usr/bin/env python
"""
This is developer software. Please read the code for details.

Example Run
    sync_pkgname.py md.alpha md.amd64
"""

import argparse
from pathlib import Path, PosixPath
from typing import Dict

Pair = Dict[str, str]


def getargs() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=str)
    parser.add_argument('dest', type=str)
    return parser.parse_args()


def get_filename_and_pkgname_pair(filepath: PosixPath) -> Pair:
    if type(filepath) is not PosixPath:
        raise TypeError
    if not filepath.exists():
        raise FileNotFoundError

    pair: dict = {}

    with filepath.open(mode='r', encoding='utf-8') as f:
        for line in f:
            if line.startswith('#') or 'obsolete' in line:
                continue

            filename, pkgname = [x for x in line.split('\t') if x][0:2]

            if pkgname == '-unknown-':
                continue

            pair[filename] = pkgname

    return pair


def sync_pkgname(pair: Pair, dest: PosixPath) -> None:
    if type(pair) is not dict or type(dest) is not PosixPath:
        raise TypeError
    if not dest.exists():
        raise FileNotFoundError

    tempfile = Path(dest.as_posix() + '.tmp')

    with tempfile.open(mode='w', encoding='utf-8') as tmp:
        with dest.open(mode='r', encoding='utf-8') as f:
            for line in f:
                filename = line.split('\t')[0]
                if filename in pair.keys():
                    tmp.write(line.replace('-unknown-', pair[filename]))
                else:
                    tmp.write(line)

    tempfile.replace(dest)


if __name__ == '__main__':
    args: argparse.Namespace = getargs()
    source: PosixPath = Path(args.source)
    dest: PosixPath = Path(args.dest)
    pair: Pair = get_filename_and_pkgname_pair(source)

    sync_pkgname(pair, dest)
