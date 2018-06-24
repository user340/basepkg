#!/usr/pkg/bin/python3.6

import os.path
import re
import sys


class NamingLists:
    def __init__(self):
        if len(sys.argv) == 1:
            self.__usage(sys.stderr)
            sys.exit(1)
        if not os.path.exists(sys.argv[1]):
            self.__bomb(sys.argv[1] + " no such file.")
        if os.path.isdir(sys.argv[1]):
            self.__bomb(sys.argv[1] + " is directory.")

    def __usage(self, output=sys.stdout):
        print('Usage:', file=output)
        print(__file__ + ' <list>', file=output)

    def __bomb(self, message=""):
        print(message, file=sys.stderr)
        sys.exit(1)

    def __xserver_output(self, category, name, mark):
        tree = name.split('/')
        if re.match('^\./usr/X11R7/bin', name):
            pname = category + '-x11-bin'
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/lib/X11/doc', name):
            pname = category + '-x11-bin'
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/lib/modules/(dri|drivers|extensions)',
                      name):
            pname = category + '-modules-' + tree[-1].split('.')[0]
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/lib/modules/fonts', name):
            pname = category + '-modules-' + tree[-1].split('.')[0]
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/lib/modules', name):
            pname = category + '-modules-' + tree[-1].split('.')[0]
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/man/cat[0-9]', name):
            pname = category + '-' + tree[-1].split('.')[0] + '-catman'
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/man/html[0-9]', name):
            pname = category + '-' + tree[-1].split('.')[0] + '-htmlman'
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/man/man[0-9]', name):
            pname = category + '-' + tree[-1].split('.')[0] + '-man'
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/share/aclocal', name):
            pname = category + '-share-' + tree[-1].split('.')[0]
            print(name + '\t' + pname + '\t' + mark)

    def rewrite_name(self, category):
        with open(sys.argv[1], encoding='utf-8') as f:
            for l in f:
                if re.match('^# ', l):
                    print(l.rstrip())
                    continue
                splited = l.split()
                if len(splited) == 0:
                    continue
                if re.match('obsolete', splited[2]):
                    print(l.rstrip())
                    continue
                name, pkg, mark = splited
                if category == 'xserver':
                    self.__xserver_output(category, name, mark)


if __name__ == '__main__':
    nl = NamingLists()
    nl.rewrite_name('xserver')
    sys.exit(0)
