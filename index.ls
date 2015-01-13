"use strict";

{docopt} = require('docopt')
_        = require('lodash')
_s       = require('underscore.string')
table    = require('easy-table')
shelljs  = require('shelljs')
bb       = require('bluebird')
shelljs  = bb.promisifyAll(shelljs)

require! 'fs'
require! 'path'
require! 'moment'


doc = shelljs.cat(__dirname+"/docs/usage.md")

# global variables
var patterns
var from
var tto
var files 
var normal
var verbose
var options
var targetProp
var o
var stored-options

# setup globals

setup-globals = ->
    patterns := { }
    options := {}
    normal := console.log 
    verbose := ->
    targetProp := ""
    o := docopt(doc)

read-patterns = ->
    try 
        if fs.existsSync("#{process.env.HOME}/.rnc") 
            patterns := JSON.parse(fs.readFileSync("#{process.env.HOME}/.rnc", "utf-8"))

        if fs.existsSync("#{__dirname}/.rnc") 
            _.extend(patterns, JSON.parse(fs.readFileSync("#{__dirname}/.rnc", "utf-8")))
    
    catch e 
        throw "Looks like your .rnc file is not well formatted. Check commas and quotes in it."

parse-options = ->

    get-option = (a, b, def, o) ->
        if not o[a] and not o[b]
            return def
        else 
            return o[b]


    options.go          := get-option('-g', '--go', false, o)
    options.keyword     := get-option('-k', '--key', 'keyword', o)
    options.use         := get-option('-u', '--use', '', o)
    options.save        := get-option('-s', '--save', '', o)
    options.include_ext := get-option('-x', '--ext', undefined, o)
    options.verb        := get-option('-v', '--verbose', false, o)
    options.transform   := get-option('-t', '--transform', undefined, o)

    files ?:= o["FILES"]

    if options.verb 
        verbose := console.log 
        normal := ->

    exist-or-throw = (v, name, message) ->
       if not v? 
            throw ("#name does not exist: #message")
       else 
            return v

    if options.use != '' 
        if patterns[options.use]?
            from := exist-or-throw(patterns[options.use].from, "property `from` in pattern #options.use", "this is mandatory")
            tto := exist-or-throw(patterns[options.use].to, "property `to` in pattern #options.use", "this is mandatory")
            stored-options := patterns[options.use].options if patterns[options.use].options?
        else
            exist-or-throw(patterns[options.use], "pattern `#{options.use}`", "specify an existing pattern");
    else
        from  := o["FROM"]
        tto   := o["TO"]


    options.transform ?:= stored-options?.transform
    options.include_ext ?:= stored-options?.include_ext 

    options.transform ?:= ''
    options.include_ext ?:= false


    targetProp := 
        | not options.include_ext    => 'basenameNoext'
        | otherwise  => 'basename'

replace-placeholders = (final) ->
    v = require('verbal-expressions')
    date-exp = v().find("$D").then("{").beginCapture().anythingBut("}").endCapture().then("}")
    for k,v of final 
        v.newName = v.newName.replace /\$(0*)N/, (s, sub) ->
            return _s.pad(k, sub.length, "0")

        v.newName = v.newName.replace date-exp, (s, sub) ->
            return moment(fs.statSync(v.original).ctime).format(sub)

        v.newName = v.newName.replace /\$K/, ->
            return options.keyword 

        v.newName = v.newName.replace /\$E/, ->
            if v.ext != "" and v.ext.length > 2 
                return v.ext.slice(1)
            else
                return "noext"

    return final



replace-patterns = (final, from, tto) ->
        if not from?
            from := '.*'
        else
            from := from.replace(/\*/, "(.*)")
            from := from.replace(/\?/, "(.*)")
            tto  = tto.replace(/\*/,"\$1")
            tto  = tto.replace(/\?/,"\$1")


        re-from = new RegExp(from)

        final = _.filter(final, -> re-from.exec(it[targetProp]))

        final = _.filter(final, -> fs.lstatSync(it.original).isFile())

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
        if options.transform != ''
            f.newName   = _s[options.transform](f.newName)

        dest-is-abs = (tto[0] == '.') or (tto[0] == "~") or (tto[0]=='/')


        addext = 
            | options.include_ext => ""
            | otherwise => f.ext

        finalNameLong = 
            | not dest-is-abs => "#{f.dirname}/#{f.newName}#addext"
            | otherwise => "#{f.newName}#addext"

        finalNameRelative = 
            | not dest-is-abs => path.relative(path.dirname(f.original), finalNameLong)
            | otherwise => finalNameLong

        _.extend(f, { finalNameLong: finalNameLong, finalNameRelative: finalNameRelative })

        if not fs.existsSync(path.dirname(f.finalNameLong)) 
            f.create = path.dirname(f.finalNameLong)

        return f

create-dirs = (final) ->
    dirs = _.uniq(_.map final, (.create))
    for d in dirs 
        verbose "mkdir -p #{d}"
        if options.go
            shelljs.mkdir('-p', d)

move = (f) ->
    normal "#{f.basename} => #{f.finalNameRelative}" 
    cmd = "mv #{f.original} #{f.finalNameLong}"
    verbose cmd
    if options.go 
        shelljs.mv(f.original, f.finalNameLong)

main = ->
    if o['-l'] or o['--list']
        console.log "Available patterns"
        console.log ""
        _.mapValues patterns, ->
            it.opts = [ ] 
            it.opts.push([ "fn: #{it.options.transform}" ])  if it.options?.transform?
            it.opts.push([ "incl. extension" ]) if it.options?.include_ext? and it.options?.include_ext
            it.opts = _s.toSentence(it.opts, ' and ')
            delete it.options if it.options?
        console.log table.printArray(_.toArray(patterns))
    else
        final = unwrap-info(files)

        # replace [from] and to
        final = replace-patterns(final, from, tto)

        # Replace sequence number and date
        final = replace-placeholders(final)

        # Compute finalNameShort and finalNameLong
        final = compute-final-name(final)

        create-dirs(final)

        bb.all([ move(f) for f in final ]).caught (-> console.log "errors found.")

try 
    setup-globals!
    read-patterns!
    parse-options!
    main!
catch e
    console.error e 
    process.exit(1)




