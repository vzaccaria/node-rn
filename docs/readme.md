# {%= name %} {%= badge("fury") %}

> {%= description %}

{%= include("install-global") %}

## TLDR; simple usage

Let's assume you have 3 pdf files in your directory: 

    a-slides.pdf 
    b-slides.pdf
    c-slide.pdf 

Then:

    rn '*-slides' 's-*' *.pdf --go

will rename only the first two files, leaving untouched the extensions:

    s-a.pdf 
    s-b.pdf
    c-slide.pdf

If you omit `--go`, it will only print the new filenames without actually changing them.

To avoid backticks around the first two patterns, you can use a question mark `?`:

    rn ?-slides s-? *.pdf --go

You can include the extension in the renaming with `-x`. For example:

    rn -x '*.pdf' '*.pdfx' *.pdf --go

will change the extensions of each file:

    a-slides.pdfx 
    b-slides.pdfx
    c-slide.pdfx



## Additional keyword substitutions

The target filename rule can include one or more keywords:

* `$..0N`: will translate to the file sequence number (padding configurable)
* `$D{date format}`: will translate to the creation date formatted as specified. It uses [momentjs format](http://momentjs.com/docs/#/displaying/format/).
* `$E`: will translate to the extension of the file (`noext` if missing)
* `$K`: will translate to the value specified with the -k option

Example:

    rn -x -k my_keyword '*.pdf' '$E/s-$K-$000N.pdf' $srcdir/*.pdf

will create a folder for each extension found (`pdf` in this case), and rename the files as follows:

* `a-slides.pdf` to `pdf/s-my_keyword-000.pdf`
* `b-slides.pdf` to `pdf/s-my_keyword-001.pdf`
* `c-slide.pdf` to `pdf/s-my_keyword-002.pdf`

Finally, you can post-process all filenames with an `underscore.string` function; eg. :

    rn '*' '*' *.pdf -t 'classify'

would yield:

    ASlides.pdf
    BSlides.pdf
    CSlide.pdf

Possible functions are: classify, underscored, camelized, (de)capitalize. Check [underscore.string](https://github.com/epeli/underscore.string) for all the other possibilities; the function must receive a string and return a string.

For using pre-saved templates see the sections below:

## General help 

```
{%= partial("usage.md") %}
```


## Templates

Renaming templates are stored in `~/.rnc` in JSON format. This file is a JSON map from template names to template data. For example, this is a rule that I named as `kelby`, since I've read about it in a book about Lightroom written by Scott Kelby; it renames all the files (by preserving the extensions) with the creation date, a keyword (specified with `-k` in the command line) and a sequence number:

```json
"kelby": {
        "name": "kelby",
        "from": "*",
        "to": "$D{YYMMDD}_$K_$000N",
        "description": "This was described in Scott Kelby's book on Lightroom"
    }
```

It can be invoked in this way:

    rn -u 'kelby' -k my_keyword *.pdf

renaming all the `pdf` files according to the template.

There is a bunch of already made and usable templates in the distribution of `rn` so check them out. You can list them with `rn -l`:

```
Available patterns

name      from  to                              description                                            opts           
--------  ----  ------------------------------  -----------------------------------------------------  ---------------
kelby     *     $D{YYMMDD}_$K_$000N             This was described in Scott Kelby's book on Lightroom                 
kelbyf    *     $D{YYMMDD}/$D{YYMMDD}_$K_$000N  As kelby, but creates a folder with creation date                     
bigfold   *     $D{YYMMDD}_$000N_*              This is what you would use in a big folder.            fn: underscored
download  *     $E/*                            Organize your Download folder, once and for all        fn: underscored
```

## Author
{%= include("author") %}

## License
{%= copyright() %}
{%= license() %}

***

{%= include("footer") %}
