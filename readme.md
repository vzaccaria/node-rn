# node-rn [![NPM version](https://badge.fury.io/js/node-rn.svg)](http://badge.fury.io/js/node-rn)

> a handy rename file script

## Install globally with [npm](npmjs.org):

```bash
npm i -g node-rn
```

## General help 

```
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



```

## Regular expression shortcuts

## Templates

Renaming templates are stored in `~/.rnc` in JSON format. This file is a JSON map from template names to objects representing:

```json
{ 
    "from":     "from regex",
    "to":       "to regex",
    "description": "description"
}
```


## Author

**Vittorio Zaccaria**
 

## License
Copyright (c) 2015 Vittorio Zaccaria  
Released under the BSD license

***

_This file was generated by [verb](https://github.com/assemble/verb) on January 10, 2015._
