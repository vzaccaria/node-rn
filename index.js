#!/usr/bin/env node
// Generated by LiveScript 1.3.1
(function(){
  "use strict";
  var docopt, _, _s, table, shelljs, bb, fs, path, moment, doc, patterns, from, tto, files, normal, verbose, options, targetProp, o, storedOptions, setupGlobals, readPatterns, parseOptions, replacePlaceholders, replacePatterns, unwrapInfo, computeFinalName, createDirs, move, main, e;
  docopt = require('docopt').docopt;
  _ = require('lodash');
  _s = require('underscore.string');
  table = require('easy-table');
  shelljs = require('shelljs');
  bb = require('bluebird');
  shelljs = bb.promisifyAll(shelljs);
  fs = require('fs');
  path = require('path');
  moment = require('moment');
  doc = shelljs.cat(__dirname + "/docs/usage.md");
  setupGlobals = function(){
    patterns = {};
    options = {};
    normal = console.log;
    verbose = function(){};
    targetProp = "";
    return o = docopt(doc);
  };
  readPatterns = function(){
    var e;
    try {
      if (fs.existsSync(process.env.HOME + "/.rnc")) {
        patterns = JSON.parse(fs.readFileSync(process.env.HOME + "/.rnc", "utf-8"));
      }
      if (fs.existsSync(__dirname + "/.rnc")) {
        return _.extend(patterns, JSON.parse(fs.readFileSync(__dirname + "/.rnc", "utf-8")));
      }
    } catch (e$) {
      e = e$;
      throw "Looks like your .rnc file is not well formatted. Check commas and quotes in it.";
    }
  };
  parseOptions = function(){
    var getOption, existOrThrow;
    getOption = function(a, b, def, o){
      if (!o[a] && !o[b]) {
        return def;
      } else {
        return o[b];
      }
    };
    options.go = getOption('-g', '--go', false, o);
    options.keyword = getOption('-k', '--key', 'keyword', o);
    options.use = getOption('-u', '--use', '', o);
    options.save = getOption('-s', '--save', '', o);
    options.include_ext = getOption('-x', '--ext', undefined, o);
    options.verb = getOption('-v', '--verbose', false, o);
    options.transform = getOption('-t', '--transform', undefined, o);
    files == null && (files = o["FILES"]);
    if (options.verb) {
      verbose = console.log;
      normal = function(){};
    }
    existOrThrow = function(v, name, message){
      if (v == null) {
        throw name + " does not exist: " + message;
      } else {
        return v;
      }
    };
    if (options.use !== '') {
      if (patterns[options.use] != null) {
        from = existOrThrow(patterns[options.use].from, "property `from` in pattern " + options + ".use", "this is mandatory");
        tto = existOrThrow(patterns[options.use].to, "property `to` in pattern " + options + ".use", "this is mandatory");
        if (patterns[options.use].options != null) {
          storedOptions = patterns[options.use].options;
        }
      } else {
        existOrThrow(patterns[options.use], "pattern `" + options.use + "`", "specify an existing pattern");
      }
    } else {
      from = o["FROM"];
      tto = o["TO"];
    }
    options.transform == null && (options.transform = storedOptions != null ? storedOptions.transform : void 8);
    options.include_ext == null && (options.include_ext = storedOptions != null ? storedOptions.include_ext : void 8);
    options.transform == null && (options.transform = '');
    options.include_ext == null && (options.include_ext = false);
    return targetProp = (function(){
      switch (false) {
      case !!options.include_ext:
        return 'basenameNoext';
      default:
        return 'basename';
      }
    }());
  };
  replacePlaceholders = function(final){
    var v, dateExp, k;
    v = require('verbal-expressions');
    dateExp = v().find("$D").then("{").beginCapture().anythingBut("}").endCapture().then("}");
    for (k in final) {
      v = final[k];
      v.newName = v.newName.replace(/\$(0*)N/, fn$);
      v.newName = v.newName.replace(dateExp, fn1$);
      v.newName = v.newName.replace(/\$K/, fn2$);
      v.newName = v.newName.replace(/\$E/, fn3$);
    }
    return final;
    function fn$(s, sub){
      return _s.pad(k, sub.length, "0");
    }
    function fn1$(s, sub){
      return moment(fs.statSync(v.original).ctime).format(sub);
    }
    function fn2$(){
      return options.keyword;
    }
    function fn3$(){
      if (v.ext !== "" && v.ext.length > 2) {
        return v.ext.slice(1);
      } else {
        return "noext";
      }
    }
  };
  replacePatterns = function(final, from, tto){
    var reFrom;
    if (from == null) {
      from = '.*';
    } else {
      from = from.replace(/\*/, "(.*)");
      from = from.replace(/\?/, "(.*)");
      tto = tto.replace(/\*/, "$1");
      tto = tto.replace(/\?/, "$1");
    }
    reFrom = new RegExp(from);
    final = _.filter(final, function(it){
      return reFrom.exec(it[targetProp]);
    });
    final = _.filter(final, function(it){
      return fs.lstatSync(it.original).isFile();
    });
    final = final.map(function(it){
      return _.extend(it, {
        newName: it[targetProp].replace(reFrom, tto)
      });
    });
    return final;
  };
  unwrapInfo = function(files){
    return _.map(files, function(it){
      it = path.normalize(it);
      return {
        original: it,
        dirname: path.dirname(it),
        ext: path.extname(it),
        basename: path.basename(it),
        basenameNoext: path.basename(it, path.extname(it))
      };
    });
  };
  computeFinalName = function(files){
    return _.map(files, function(f){
      var destIsAbs, addext, finalNameLong, finalNameRelative;
      if (options.transform !== '') {
        f.newName = _s[options.transform](f.newName);
      }
      destIsAbs = tto[0] === '.' || tto[0] === "~" || tto[0] === '/';
      addext = (function(){
        switch (false) {
        case !options.include_ext:
          return "";
        default:
          return f.ext;
        }
      }());
      finalNameLong = (function(){
        switch (false) {
        case !!destIsAbs:
          return f.dirname + "/" + f.newName + addext;
        default:
          return f.newName + "" + addext;
        }
      }());
      finalNameRelative = (function(){
        switch (false) {
        case !!destIsAbs:
          return path.relative(path.dirname(f.original), finalNameLong);
        default:
          return finalNameLong;
        }
      }());
      _.extend(f, {
        finalNameLong: finalNameLong,
        finalNameRelative: finalNameRelative
      });
      if (!fs.existsSync(path.dirname(f.finalNameLong))) {
        f.create = path.dirname(f.finalNameLong);
      }
      return f;
    });
  };
  createDirs = function(final){
    var dirs, i$, len$, d, results$ = [];
    dirs = _.uniq(_.map(final, function(it){
      return it.create;
    }));
    for (i$ = 0, len$ = dirs.length; i$ < len$; ++i$) {
      d = dirs[i$];
      verbose("mkdir -p " + d);
      if (options.go) {
        results$.push(shelljs.mkdir('-p', d));
      }
    }
    return results$;
  };
  move = function(f){
    var cmd;
    normal(f.basename + " => " + f.finalNameRelative);
    cmd = "mv " + f.original + " " + f.finalNameLong;
    verbose(cmd);
    if (options.go) {
      return shelljs.mv(f.original, f.finalNameLong);
    }
  };
  main = function(){
    var final, f;
    if (o['-l'] || o['--list']) {
      console.log("Available patterns");
      console.log("");
      _.mapValues(patterns, function(it){
        var ref$, ref1$, ref2$, ref3$;
        it.opts = [];
        if (((ref$ = it.options) != null ? ref$.transform : void 8) != null) {
          it.opts.push(["fn: " + it.options.transform]);
        }
        if (((ref1$ = it.options) != null ? ref1$.include_ext : void 8) != null && ((ref2$ = it.options) != null && ref2$.include_ext)) {
          it.opts.push(["incl. extension"]);
        }
        it.opts = _s.toSentence(it.opts, ' and ');
        if (it.options != null) {
          return ref3$ = it.options, delete it.options, ref3$;
        }
      });
      return console.log(table.printArray(_.toArray(patterns)));
    } else {
      final = unwrapInfo(files);
      final = replacePatterns(final, from, tto);
      final = replacePlaceholders(final);
      final = computeFinalName(final);
      createDirs(final);
      return bb.all((function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = final).length; i$ < len$; ++i$) {
          f = ref$[i$];
          results$.push(move(f));
        }
        return results$;
      }())).caught(function(){
        return console.log("errors found.");
      });
    }
  };
  try {
    setupGlobals();
    readPatterns();
    parseOptions();
    main();
  } catch (e$) {
    e = e$;
    console.error(e);
    process.exit(1);
  }
}).call(this);
