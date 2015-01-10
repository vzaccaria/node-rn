Usage:
    rn -l | --list 
    rn -u NAME [ -k KEY ] [ -x ] [ -g ] [ -v ] FILES ...
    rn [ -s NAME ] FROM TO [ -k KEY ] [ -x ] [ -g ] [ -v ] [ -f FUN ] FILES ...
    rn -h | --help 

Options:
    -g, --go            Execute rename, otherwise is dry-run
    -u, --use NAME      Use template stored as NAME
    -s, --save NAME     Save template stored as NAME
    -l, --list          Show templates
    -k, --key KEY       Define a keyword to be used in the TO pattern as $K
    -x, --ext           Interpret extension as part of the substitution pattern 
    -v, --verbose       Additional info
    -f, --finally FUN   Underscore.string function to apply at the end.


