BEGIN {
    FS = ","
    OFS = ","
}

/^@/ { print; next }

{
    label = $1

    # shift fields left
    for (i = 1; i < NF; i++) {
        $i = $(i+1)
    }

    # rebuild last field with colon + label
    $NF = $NF ":" label

    print
}
