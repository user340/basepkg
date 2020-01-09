# Ignore comment
! /^\#/ {
    # Ignore obsolete packages.
    if ($2 == category"-obsolete")
        next
    # Ignore package with obsolete tags.
    if ($3 ~ "obsolete")
        next
    if ($2 ~ category) {
        # Remove "./" characters.
        $1 = substr($1, 3);
        if ($1 != "") {
            gsub(/@MODULEDIR@/, moduledir);
            gsub(/@MACHINE@/, machine);
            gsub(/@OSRELEASE@/, release_k);
            print
        }
    }
}
