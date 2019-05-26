#!/usr/bin/env python

import os
import unittest
from lib import taker


class TestTakeValidMachineArch(unittest.TestCase):
    def setUp(self):
        self.taker = taker.TakeValidMachineArch()
        self.path = '/usr/src/build.sh'
        self.test_file = './taker_output.txt'

    def tearDown(self):
        if os.path.exists(self.test_file):
            os.remove(self.test_file)

    def test_taker(self):
        abnormal_cases = [None, True, 0, 1.127, [1, 2], {1, 2}, {'test': 'a'}]
        for i in abnormal_cases:
            self.assertRaises(TypeError, self.taker.taker, i)
        self.assertRaises(FileNotFoundError, self.taker.taker, 'jkjkljljkkj')
        taked = self.taker.taker(self.path)
        self.assertIsInstance(taked, list)
        print(taked)

    def test_writer(self):
        abnormal_cases = [None, True, 0, 1.127, [1, 2], {1, 2}, {'test': 'a'}]
        for i in abnormal_cases:
            for j in abnormal_cases:
                self.assertRaises(TypeError, self.taker.writer, i, j)
        test_data = [
            'valid_MACHINE_ARCH=\'\n'
            'MACHINE=acorn26\t\tMACHINE_ARCH=arm\n',
            'MACHINE=acorn32\t\tMACHINE_ARCH=arm\n',
            'MACHINE=algor\t\tMACHINE_ARCH=mips64el\tALIAS=algor64\n',
            'MACHINE=algor\t\tMACHINE_ARCH=mipsel\tDEFAULT\n',
            'MACHINE=alpha\t\tMACHINE_ARCH=alpha\n',
            'MACHINE=amd64\t\tMACHINE_ARCH=x86_64\n',
            'MACHINE=amiga\t\tMACHINE_ARCH=m68k\n',
            'MACHINE=amigappc\tMACHINE_ARCH=powerpc\n',
            'MACHINE=arc\t\tMACHINE_ARCH=mips64el\tALIAS=arc64\n',
            'MACHINE=arc\t\tMACHINE_ARCH=mipsel\tDEFAULT\n',
            'MACHINE=atari\t\tMACHINE_ARCH=m68k\n',
            'MACHINE=bebox\t\tMACHINE_ARCH=powerpc\n',
            'MACHINE=cats\t\tMACHINE_ARCH=arm\tALIAS=ocats\n',
            'MACHINE=cats\t\tMACHINE_ARCH=earmv4\tALIAS=ecats DEFAULT\n',
            'MACHINE=cesfic\t\tMACHINE_ARCH=m68k\n',
            'MACHINE=cobalt\t\tMACHINE_ARCH=mips64el\tALIAS=cobalt64\n',
            'MACHINE=cobalt\t\tMACHINE_ARCH=mipsel\tDEFAULT\n',
            '\'\n'
        ]
        self.taker.writer(self.test_file, test_data)
        with open(self.test_file, mode='r', encoding='utf-8') as f:
            for line in f:
                print(line, end='')
