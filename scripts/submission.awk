# add fake class to solve load problem
BEGIN {
    FS = ","
    OFS = ","
}

{ print $0 ":-1" } 
