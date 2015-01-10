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
    rn (-u NAME | --use NAME) FILES ...
    rn [ -s NAME | --save NAME ] FROM TO [ -g | --go ] [ -X | --eXt ] FILES ...
    rn -h | --help 

Options:
    -g, --go          Execute rename, otherwise is dry-run
    -u, --use NAME    Use template stored as NAME
    -s, --save NAME   Save template stored as NAME
    -l, --list        Show templates
    -X, --ext         Discard extension on file name matches



```

## Regular expression shortcuts

## Templates

Renaming templates are stored in `~/.rnc` in JSON format. Each template is a JSON object with the following properties:

```json
{ 
    "name":     "template-name",
    "from":     "from regex",
    "to":       "to regex",
    "options":  "other options to rn"
}
```


## Author

**Vittorio Zaccaria**
 

## License
Copyright (c) 2015 Vittorio Zaccaria  
Released under the BSD license

***

_This file was generated by [verb](https://github.com/assemble/verb) on January 10, 2015._
