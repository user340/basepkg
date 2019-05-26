#!/usr/bin/env python

from distutils.core import setup

setup(
    name='sync_valid_MACHINE_ARCH',
    version='1.0',
    description='Take valid_MACHINE_ARCH definition from given build.sh.',
    author='Yuuki Enomoto',
    author_email='uki@e-yuuki.org',
    license='BSD-2-Clause',
    url='https://github.com/user340/basepkg',
    package_dir={'': 'src'},
    py_modules=['lib.taker'],
    scripts=['src/sync_valid_MACHINE_ARCH.py'],
)
