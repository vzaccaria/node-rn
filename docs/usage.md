Usage:
    rn -l | --list 
    rn -u NAME [ -k KEY ] [ -x ] [ -g ] [ -v ] FILES ...
    rn FROM TO [ -k KEY ] [ -x ] [ -g ] [ -v ] [ -t T ] FILES ...
    rn -h | --help 

Options:
    -g, --go            Execute rename, otherwise is dry-run
    -u, --use NAME      Use template stored as NAME in $HOME/.rnc
    -l, --list          Show templates
    -k, --key KEY       Define a keyword to be used in the TO pattern as $K
    -x, --ext           Interpret extension as part of the substitution pattern 
    -v, --verbose       Additional info
    -t, --transform T   Underscore.string function to apply at the end.


