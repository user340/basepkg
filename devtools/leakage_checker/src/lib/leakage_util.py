#!/usr/bin/env python


class LeakageUtil:
    def __init__(self):
        self.valid_categories = (
            'base', 'comp', 'debug', 'etc', 'games', 'man', 'misc',
            'modules', 'tests', 'text', 'xbase', 'xcomp', 'xdebug',
            'xetc', 'xfont', 'xserver'
        )  # Immutable

    def category_validator(self, category: str) -> bool:
        """ Validate given category name

        Arguments:
            category: category name

        Returns:
            bool: valid if true, otherwise false
        """
        if type(category) is not str:
            raise TypeError
        if category in self.valid_categories:
            return True
        else:
            return False

    def get_pkg(self, category: str) -> set:
        """ Get package name from given category as set

        Arguments:
            category: category name

        Returns:
            set: set of package names which are belong of given category
        """
        if type(category) is not str:
            raise TypeError
        self.category_validator(category)

    def get_all_pkg(self, categories: set) -> set:
        """Get all package name from given list of categories as set

        Arguments:
            categories: set of category names
                        e.x.) ("base", "etc", "comp")
        Returns:
            set: set of package name
        """
        if type(categories) is not set:
            raise TypeError
        pkgs: set = set()
        for category in categories:
            pkgs = pkgs.union(self.get_pkg(category))
        return pkgs
