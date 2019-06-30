#!/usr/bin/env python

import os


class TakeValidMachineArch():
    def __init__(self):
        pass

    def taker(self, path: str) -> list:
        if type(path) is not str:
            raise TypeError
        if not os.path.exists(path):
            raise FileNotFoundError
        valid_MACHINE_ARCH = []
        append_mode = False
        with open(path, mode='r', encoding='utf-8') as f:
            for line in f.readlines():
                """
                Taking RCS id and copyright notice zone.
                """
                if line.startswith('#\t$NetBSD: build.sh,'):
                    valid_MACHINE_ARCH.append(line + '#\n')
                    continue
                if line.startswith('# Copyright (c) 2001-'):
                    append_mode = True
                    valid_MACHINE_ARCH.append(line)
                    continue
                if line.startswith('# POSSIBILITY OF SUCH DAMAGE.'):
                    append_mode = False
                    valid_MACHINE_ARCH.append(line + '#\n')
                    continue
                """
                Taking valid_MACHINE_ARCH zone.
                """
                if line.startswith('valid_MACHINE_ARCH=\''):
                    append_mode = True
                    valid_MACHINE_ARCH.append(line)
                    continue
                if append_mode and line.startswith('\''):
                    valid_MACHINE_ARCH.append(line)
                    break
                if append_mode:
                    valid_MACHINE_ARCH.append(line)
        return valid_MACHINE_ARCH

    def writer(self, path: str, data: list) -> None:
        if type(path) is not str or type(data) is not list:
            raise TypeError
        with open(path, mode='w', encoding='utf-8') as f:
            for line in data:
                f.write(line)
