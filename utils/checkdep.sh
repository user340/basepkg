obj="/usr/obj"
destdir="$obj/destdir.amd64"
sets="../sets"
lists="$sets/lists"
deps="$sets/deps"
info="$lists/$(printf "$1" | cut -d "-" -f 1)"

fn_deps()
{
    grep "^$1" "$deps" > /dev/null 2>&1 || return 1 # unknown dependency.
    awk '/^'"$1"'/{print $2}' "$deps" | while read -r depend; do
        test ! "$depend" && return 1
        test "$depend" = "base-sys-root" && { printf "$depend"; return 0; }
        printf "$depend "
        fn_deps "$depend" # Recursion.
    done
}

fn_get_bin()
{
    grep -h "$1" "$info"/* \
    | grep -E '^\./bin|^\./usr/bin|^\./sbin|^\./usr/sbin' \
    | cut -f 1 \
    | sed "s%^\.%$destdir%"
}

fn_ldd()
{
 (
    fn_get_bin "$1" | while read -r prog; do
        test -f "$prog" && ldd -f "%p\n" "$prog" | sed 's%^/%./%g' | tr '\n' ' '
    done
 ) | tr ' ' '\n' | sort | uniq | tr '\n' ' '
}

fn_all_ldd()
{
 (
    for i in $1 $2; do
        fn_ldd "$i"
    done
 )
}

fn_print_necessary_pkg()
{
 (
    for i in $libs; do
        printf "%s\n" \
        "$(grep -h -r "$i" "$lists"/* \
            | grep -v "debug" \
            | awk '{print $2}' \
            | sort | uniq)"
    done
 ) | sort | uniq | tr '\n' ' '
}

fn_print_lacking_pkg()
{
    for i in $necessary; do
        for j in $depend; do
            ok="false"
            test "$i" = "$j" && ok="true"
        done
        test "$ok" = "false" && printf "not including %s\n" "$i"
    done
}

# 1. Get dependency infomation
depend=$(fn_deps "$1" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')

# 2. Get libraries that required.
libs=$(fn_all_ldd "$1" "$depend")

# 3. Get necessary package information.
necessary=$(fn_print_necessary_pkg)

fn_print_lacking_pkg
