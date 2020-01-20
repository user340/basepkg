#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

test_split_category()
{
    _logging()
    {
        :
    }
    _mkdir_if_not_exists()
    {
        :
    }
    _remove_if_exists()
    {
        :
    }
    _print_if_file_exists()
    {
        echo "/tmp/test_split_category"
    }

    local machine="amd64"
    local release_k="9.99.36"
    local lists="."
    local workdir=""
    local libbasepkg="../lib"
    local expected="xxx test-example-package test
xxx test-example-package test
xxx test-example-package test
xxx test-example-package test
xxx test-example-package test
xxx test-example-package test
xxx test-example-package test
xxx test-example-package test
xxx test-example-package test"
    local result

    echo "./xxx	test-example-package	test" > /tmp/test_split_category

    result="$(_split_category "test")"

    assertEquals "$expected" "$result"

    rm -f /tmp/test_split_category
}

test_split_categories()
{
    _split_category()
    {
        echo -n "$@"
    }

    local category="base comp etc debug"
    local workdir="./test_split_categories"

    for i in $category; do
        mkdir -p "${workdir}/${i}"
    done

    _split_categories

    for i in $category; do
        assertTrue "[ -f ${workdir}/${i}/FILES ]"
        assertEquals "$i" "$(cat "${workdir}/${i}/FILES")"
    done

    rm -fr "$workdir"
}

test_make_package_directories()
{
    _setup()
    {
        mkdir "$workdir/$category"
        echo "test01 test-01-package" > "$workdir/$category/FILES"
        echo "test02 test-02-package" >> "$workdir/$category/FILES"
        echo "test03 test-03-package" >> "$workdir/$category/FILES"
    }

    _cleanup()
    {
        test -d "$workdir/$category" && rm -fr "$workdir/$category"
    }

    _logging()
    {
        :
    }

    local category="test_basepkg"
    local workdir="/tmp"

    _setup
    _make_package_directories

    assertTrue "[ -d $workdir/$category/test-01-package ]"
    assertTrue "[ -d $workdir/$category/test-02-package ]"
    assertTrue "[ -d $workdir/$category/test-03-package ]"

    _cleanup
}

. ./common.sh
. ../lib/Package
. ../lib/Logging
. "$SHUNIT2"
