#!/usr/pkg/bin/python3.7
#
# It is filter script. It doesn't open any file.
# EXAMPLE
#   $ cat ../sets/lists/xbase/mi | ./xpkg.py xbase
# or
#   $ ./xpkg.py xbase < ../sets/lists/xbase/mi

import argparse
import re
import sys


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
                 help='specify the category name of under the sets/lists')
args = arg.parse_args()
category = args.category

# Main
# It calls xnaming() function line by line from stdin. The xnaming() function
# works for only replacing text.
[xnaming(line, category) for line in iter(sys.stdin.readline, "")]
