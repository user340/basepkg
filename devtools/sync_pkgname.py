#!/usr/pkg/bin/python3.7
"""
This is developer software. Please read the code for details.

Example Run
    sync_pkgname.py md.alpha md.amd64
"""

import argparse
import os
from typing import Dict

Pair = Dict[str, str]


def getargs() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=str)
    parser.add_argument('dest', type=str)
    return parser.parse_args()


def get_filename_and_pkgname_pair(filepath: str) -> Pair:
    if type(filepath) is not str:
        raise TypeError
    if not os.path.exists(filepath):
        raise FileNotFoundError

    pair: dict = {}

    with open(filepath, mode='r', encoding='utf-8') as f:
        for line in f:
            if line.startswith('#') or 'obsolete' in line:
                continue

            filename, pkgname = [x for x in line.split('\t') if x][0:2]

            if pkgname == '-unknown-':
                continue

            pair[filename] = pkgname

    return pair


def sync_pkgname(pair: Pair, dest: str) -> None:
    if type(pair) is not dict or type(dest) is not str:
        raise TypeError
    if not os.path.exists(dest):
        raise FileNotFoundError

    with open(dest, mode='r', encoding='utf-8') as f:
        for line in f:
            filename = line.split('\t')[0]
            if filename in pair.keys():
                print(line.replace('-unknown-', pair[filename]), end='')
            else:
                print(line, end='')


if __name__ == '__main__':
    args: argparse.Namespace = getargs()
    pair: Pair = get_filename_and_pkgname_pair(args.source)
    sync_pkgname(pair, args.dest)
