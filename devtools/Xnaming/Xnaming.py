#!/usr/pkg/bin/python3.6
#
# Copyright (c) 2018 Yuuki Enomoto
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Xnaming.py -- Naming X11 packages

import os.path
import re
import sys


class NamingLists:
    def __init__(self):
        self.supports = ['base', 'comp', 'debug', 'etc', 'games', 'man',
                         'misc', 'modules', 'tests', 'text', 'xbase', 'xcomp',
                         'xdebug', 'xetc', 'xfont', 'xserver']

        if len(sys.argv) == 1:
            self.__usage(sys.stderr)
            sys.exit(1)
        if not os.path.exists(sys.argv[1]):
            self.__bomb(sys.argv[1] + " no such file.")
        if os.path.isdir(sys.argv[1]):
            self.__bomb(sys.argv[1] + " is directory.")

    def __usage(self, output=sys.stdout):
        print('Usage:', file=output)
        print('    ' + __file__ + ' <category> <list>', file=output)
        print('', file=output)
        print('Example:', file=output)
        print('    ' + __file__ + ' xserver md.amd64')

    def __bomb(self, message=""):
        print(message, file=sys.stderr)
        sys.exit(1)

    def __base_output(self, category, name, mark):
        pass

    def __comp_output(self, category, name, mark):
        pass

    def __debug_output(self, category, name, mark):
        pass

    def __etc_output(self, category, name, mark):
        pass

    def __games_output(self, category, name, mark):
        pass

    def __man_output(self, category, name, mark):
        pass

    def __misc_output(self, category, name, mark):
        pass

    def __modules_output(self, category, name, mark):
        pass

    def __tests_output(self, category, name, mark):
        pass

    def __text_output(self, category, name, mark):
        pass

    def __xbase_output(self, category, name, mark):
        pass

    def __xcomp_output(self, category, name, mark):
        pass

    def __xdebug_output(self, category, name, mark):
        pass

    def __xetc_output(self, category, name, mark):
        pass

    def __xfont_output(self, category, name, mark):
        pass

    def __xserver_output(self, category, name, mark):
        tree = name.split('/')
        if re.match('^\./etc/mtree/set.xserver$', name):
            pname = 'xserver-sys-root'
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/bin', name):
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
            pname = category + '-x11-catman'
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/man/html[0-9]', name):
            pname = category + '-x11-htmlman'
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/man/man[0-9]', name):
            pname = category + '-x11-man'
            print(name + '\t' + pname + '\t' + mark)
        elif re.match('^\./usr/X11R7/share/aclocal', name):
            pname = category + '-share-' + tree[-1].split('.')[0]
            print(name + '\t' + pname + '\t' + mark)

    def rewrite_name(self):
        try:
            category = os.path.abspath(sys.argv[1]).split('/')[-2]
            if category not in self.supports:
                self.__bomb(category + ' category is not supported')
            with open(sys.argv[1], encoding='utf-8') as f:
                for l in f:
                    if re.match('^#', l):
                        print(l.rstrip())
                        continue
                    splited = l.split()
                    if len(splited) < 3:
                        print(l)
                        continue
                    if re.match('obsolete', splited[2]):
                        print(l.rstrip())
                        continue
                    name, pkg, mark = splited
                    if category == 'base':
                        self.__base_output(category, name, mark)
                    if category == 'comp':
                        self.__comp_output(category, name, mark)
                    if category == 'debug':
                        self.__debug_output(category, name, mark)
                    if category == 'etc':
                        self.__etc_output(category, name, mark)
                    if category == 'games':
                        self.__games_output(category, name, mark)
                    if category == 'man':
                        self.__man_output(category, name, mark)
                    if category == 'misc':
                        self.__misc_output(category, name, mark)
                    if category == 'modules':
                        self.__modules_output(category, name, mark)
                    if category == 'tests':
                        self.__tests_output(category, name, mark)
                    if category == 'text':
                        self.__text_output(category, name, mark)
                    if category == 'xbase':
                        self.__xbase_output(category, name, mark)
                    if category == 'xcomp':
                        self.__xcomp_output(category, name, mark)
                    if category == 'xdebug':
                        self.__xdebug_output(category, name, mark)
                    if category == 'xetc':
                        self.__xetc_output(category, name, mark)
                    if category == 'xfont':
                        self.__xfont_output(category, name, mark)
                    if category == 'xserver':
                        self.__xserver_output(category, name, mark)
        except ValueError as e:
            print(__file__ + ' ' + sys.argv[1], file=sys.stderr)
            print(splited, file=sys.stderr)
            print(e, file=sys.stderr)


if __name__ == '__main__':
    nl = NamingLists()
    nl.rewrite_name()
    sys.exit(0)
