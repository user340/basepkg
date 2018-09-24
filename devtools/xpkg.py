#!/usr/pkg/bin/python3.7

import argparse
import os
import re
import subprocess


def locating(filename):
    arguments = ["find", "/usr/obj", "-name", filename]
    result = subprocess.run(arguments, stdout=subprocess.PIPE, timeout=10)
    # print(result.stdout.decode('utf-8'))
    return result.stdout.decode('utf-8')


def naming(line):
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


listdir = '../sets/lists'
try:
    # Firstly, Is listdir (in default, ../sets/lists) exits?
    if not os.path.isdir(listdir):
        raise NotADirectoryError(listdir + ' is not directory')

    # Parse arguments.
    arg = argparse.ArgumentParser()
    arg.add_argument('category',
                     help='specify the category name of under the sets/lists')
    arg.add_argument('filename',
                     help='specify the filename of the category')
    args = arg.parse_args()
    category = args.category
    filename = args.filename
    target = os.path.join(listdir, category, filename)

    # Is target file exits?
    if not os.path.isfile(target):
        raise FileNotFoundError(target + ': no such file')

    # Open the target file.
    with open(target, mode='r', encoding='utf-8') as f:
        [naming(line) for line in f]
except FileNotFoundError:
    raise
except NotADirectoryError:
    raise
except OSError:
    raise
except subprocess.TimeoutExpired:
    raise
except subprocess.CalledProcessError:
    raise
