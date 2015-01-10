# {%= name %} {%= badge("fury") %}

> {%= description %}

{%= include("install-global") %}

## General help 

```
{%= partial("usage.md") %}
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
{%= include("author") %}

## License
{%= copyright() %}
{%= license() %}

***

{%= include("footer") %}
