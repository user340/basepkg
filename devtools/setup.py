#!/usr/bin/env python

from distutils.core import setup

author = 'Yuuki Enomoto'
author_email = 'uki@e-yuuki.org'
license = 'BSD-2-Clause'
url = 'https://github.com/user340/basepkg'

setup(
    name='sync_valid_MACHINE_ARCH',
    version='1.0',
    description='Take valid_MACHINE_ARCH definition from given build.sh.',
    author=author,
    author_email=author_email,
    license=license,
    url=url,
    package_dir={'': 'sync_valid_MACHINE_ARCH/src'},
    py_modules=['lib.taker'],
    scripts=['sync_valid_MACHINE_ARCH/src/sync_valid_MACHINE_ARCH.py'],
)

setup(
    name='leakage_checker',
    version='1.0',
    description='Check leakage of comment/description/deps in metadata',
    author=author,
    author_email=author_email,
    license=license,
    url=url,
    package_dir={'': 'src'},
    py_modules=[''],
    scripts=['src/leakage_checker.py'],
)
