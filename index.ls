
{docopt} = require('docopt')
_        = require('lodash')

require! 'fs'
require! 'path'
require! 'moment'


_s      = require('underscore.string')
v       = require('verbal-expressions')
table   = require('easy-table')
shelljs = require('shelljs')
bb      = require('bluebird')

shelljs = bb.promisifyAll(shelljs)

doc = shelljs.cat(__dirname+"/docs/usage.md")

patterns = { }

if fs.existsSync("#{process.env.HOME}/.rnc") 
    patterns := JSON.parse(fs.readFileSync("#{process.env.HOME}/.rnc", "utf-8"))

if fs.existsSync("#{__dirname}/.rnc") 
    _.extend(patterns, JSON.parse(fs.readFileSync("#{__dirname}/.rnc", "utf-8")))

get-option = (a, b, def, o) ->
    if not o[a] and not o[b]
        return def
    else 
        return o[b]

o = docopt(doc)

go      = get-option('-g', '--go', false, o)
keyword = get-option('-k', '--key', 'keyword', o)
use     = get-option('-u', '--use', '', o)
save    = get-option('-s', '--save', '', o)
ext     = get-option('-x', '--ext', false, o)
verb    = get-option('-v', '--verbose', false, o)
fin     = get-option('-f', '--finally', '', o)

normal = console.log 
verbose = ->

if verb 
    verbose := console.log 

targetProp = 
    | not ext    => 'basenameNoext'
    | otherwise  => 'basename'



files = o["FILES"]

from  = o["FROM"]
tto   = o["TO"]

if use != '' 
    if patterns[use]?
        from := patterns[use].from
        tto := patterns[use].to
    else
        console.log "Sorry, pattern #use does not exist"


date-exp = v().find("$D").then("{").beginCapture().anythingBut("}").endCapture().then("}")

replace-sequence-and-date = (final) ->
    for k,v of final 
        v.newName = v.newName.replace /\$(0*)N/, (s, sub) ->
            return _s.pad(k, sub.length, "0")

        v.newName = v.newName.replace date-exp, (s, sub) ->
            return moment(fs.statSync(v.original).ctime).format(sub)

        v.newName = v.newName.replace /\$K/, ->
            return keyword 

        v.newName = v.newName.replace /\$E/, ->
            return v.ext.slice(1)

    return final

compute-dest-dir = (final) ->
    for f in final
        f.finalName = "#{f.dirname}/#{f.newName}"
        if not fs.existsSync(path.dirname(f.finalName)) 
            f.create = path.dirname(f.finalName)
    return final

replace-patterns = (final, from, tto) ->
        if not from?
            from := '*'
        else
            from := from.replace(/\*/, "(.*)")
            tto  = tto.replace(/\*/,"\$1")

        re-from = new RegExp(from)

        final   = _.filter(final, -> re-from.exec(it[targetProp]))

        final   = final.map -> 
            _.extend(it, { newName: it[targetProp].replace(re-from, tto) })

        return final 

unwrap-info = (files) ->
        return _.map files, ->
            it = path.normalize(it)
            return {   
                original: it, 
                dirname: path.dirname(it), 
                ext: path.extname(it),
                basename: path.basename(it), 
                basenameNoext: path.basename(it, path.extname(it)) }

compute-final-name = (files) ->
    return _.map files, (f) ->
        if fin != ''
            f.newName = _s[fin](f.newName)

        finalNameLong = 
            | ext       => "#{f.dirname}/#{f.newName}"
            | otherwise => "#{f.dirname}/#{f.newName}#{f.ext}"

        finalNameRelative = path.relative(path.dirname(f.original), finalNameLong)

        _.extend(f, { finalNameLong: finalNameLong, finalNameRelative: finalNameRelative })

        if f.create? 
            createRelative = path.relative(path.dirname(f.original), f.create)
            _.extend(f, { createRelative: createRelative})

        return f

move = (f) ->
    if f.create? 
        normal  "Create #{f.createRelative}"
        verbose "mkdir -p #{f.create}"
        if go
            shelljs.mkdir('-p', f.create)

    normal "From: #{f.basename} to #{f.finalNameRelative}" 
    cmd = "mv #{f.original} #{f.finalNameLong}"
    verbose cmd
    if go 
        shelljs.execAsync(cmd)

if o['-l'] or o['--list']
    console.log "Available patterns"
    console.log ""
    console.log table.printArray(_.toArray(patterns))
else
    final = unwrap-info(files)

    # replace [from] and to
    final = replace-patterns(final, from, tto)

    # Replace sequence number and date
    final = replace-sequence-and-date(final)

    # Check if it should create a directory
    final = compute-dest-dir(final)

    # Compute finalNameShort and finalNameLong
    final = compute-final-name(final)

    bb.all([ move(f) for f in final ]).caught (-> console.log "errors found.")






