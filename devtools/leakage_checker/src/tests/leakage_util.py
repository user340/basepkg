#!/usr/bin/env python

import unittest
from lib import leakage_util
from typing import Any


class TestLeakageUtil(unittest.TestCase):
    def setUp(self) -> None:
        self.leakage_util = leakage_util.LeakageUtil()

    def tearDown(self) -> None:
        pass

    def check_args_type(self, method: Any, excepted: Any = None) -> None:
        patterns = [
            0, -149, 3.141592, 'string', [1, 2], {1, 2},
            {'test': 'dict'}, ('xx', 'y'), True, None
        ]
        for pattern in patterns:
            if excepted == type(pattern):
                continue
            self.assertRaises(TypeError, method, pattern)

    def test_category_validator(self) -> None:
        self.check_args_type(
            self.leakage_util.category_validator,
            excepted=str
        )
        self.assertFalse(self.leakage_util.category_validator('xxxxxxx'))
        for category in self.leakage_util.valid_categories:
            self.assertTrue(
                self.leakage_util.category_validator(category)
            )

    def test_get_pkg(self) -> None:
        self.check_args_type(self.leakage_util.get_pkg, excepted=str)
        self.assertIsInstance(self.leakage_util.get_pkg('base'), set)

    def test_get_all_pkg(self) -> None:
        self.check_args_type(self.leakage_util.get_all_pkg, excepted=set)
        self.assertIsInstance(
            self.leakage_util.get_all_pkg(self.leakage_util.valid_categories),
            set
        )
