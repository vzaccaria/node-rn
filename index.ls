
{docopt} = require('docopt')
_ = require('lodash')
require! 'fs'
require! 'path'

shelljs = require('shelljs')

doc = shelljs.cat(__dirname+"/docs/usage.md")


get-option = (a, b, def, o) ->
    if not o[a] and not o[b]
        return def
    else 
        return o[b]

o = docopt(doc)

go = get-option('-g', '--go', false, o)

from  = o["FROM"]
tto   = o["TO"]
files = o["FILES"]


if o['ls'] or o['list']
    console.log "ls"
else
    from = from.replace(/\*/, "(.*)")
    tto  = tto.replace(/\*/,"\$1")

    processed = _.map files, ->
        it = path.normalize(it)
        { original: it, basename: path.basename(it), dirname: path.dirname(it), basename-noext: path.basename(it, path.extname(it)) }

    re-from = new RegExp(from)

    matched = _.filter(processed, -> re-from.exec(it.basename))

    final = matched.map ->
        _.extend(it, { newName: it.basename.replace(re-from, tto) })

    if not go 
        _.forEach final, ->
            console.log "From: #{it.original} to #{it.dirname}/#{it.newName}"
    else
        console.log "Should be doing something here"






