#!/usr/pkg/bin/python3.7
#
# It is filter script. It doesn't open any file.
# EXAMPLE
#   $ cat ../sets/lists/xbase/mi | ./xpkg.py xbase
# or
#   $ ./xpkg.py xbase < ../sets/lists/xbase/mi

import argparse
import os
import re
import sys


def find_result(top):
    return {os.path.join(root, name)
                for root, _, files in os.walk(top) for name in files}


def xnaming(line, category):
    # It may includes empty items. So remove it.
    colums = [colum for colum in line.split('\t') if colum]
    # Usually a line contains three colums. But it sometimes contains two
    # colums. We must watch out for this.
    if len(colums) < 3:
        print(line, end='')
    # Already named.
    elif re.match('\\w+-\\w+-\\w+', colums[1]):
        print(line, end='')
    # Requirements of xxx-x11-bin package.
    elif colums[0].startswith('./usr/X11R7/bin'):
        print(colums[0] + '\t' + category + '-x11-bin\t' + colums[2], end='')
    # Requirements of obsolete package.
    elif colums[2].startswith('obsolete'):
        print(colums[0] + '\t' + category + '-obsolete\t' + colums[2], end='')
    else:
        print(line, end='')


# Parse arguments.
arg = argparse.ArgumentParser()
arg.add_argument('category',
                 help='Specify the category name of under the sets/lists')
arg.add_argument('--objdir', '-O',
                 type=str,
                 help='Set object root directory.')
args = arg.parse_args()
category = args.category
objdir = '/usr/obj' if args.objdir is None else args.objdir

# Main
# It calls xnaming() function line by line from stdin. The xnaming() function
# works for only replacing text.
#[xnaming(line, category) for line in iter(sys.stdin.readline, "")]
