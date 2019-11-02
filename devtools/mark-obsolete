#!/usr/bin/env python

import argparse
import re
from pathlib import Path
from lib import common

parser = argparse.ArgumentParser()
parser.add_argument('set', type=str)
parser.add_argument('file', type=str)
args = parser.parse_args()

original = Path(args.file)
tempfile = Path(original.as_posix() + '.tmp')
del args.file

if args.set not in common.NetBSD_sets:
    raise ValueError(f'{args.set} is not NetBSD binary sets')
if not original.exists():
    # Retry
    failed = original
    original = Path(common.NetBSD_src_dir).expanduser() / 'distrib' \
                                                        / 'sets' \
                                                        / 'lists' \
                                                        / args.set \
                                                        / original.as_posix()
    if not original.exists():
        raise FileNotFoundError(
            f'I tried search {failed} and {original} but not found them.'
        )
    del failed
if tempfile.exists():
    tempfile.unlink()

with tempfile.open(mode='w', encoding='utf-8') as tmp:
    with original.open(mode='r', encoding='utf-8') as f:
        for line in f:
            if re.search(r'[\t,]obsolete', line):
                tmp.write(line.replace('-unknown-', f'{args.set}-obsolete'))
            else:
                tmp.write(line)

tempfile.replace(original)
