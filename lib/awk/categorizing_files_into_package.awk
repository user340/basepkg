# $1 - file name
# $2 - package name
{
    if ($2 in lists)
        lists[$2] = $1 " " lists[$2]
    else
        lists[$2] = $1
}
END {
    for (pkg in lists)
        print pkg, lists[pkg]
}
