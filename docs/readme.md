# {%= name %} {%= badge("fury") %}

> {%= description %}

{%= include("install-global") %}

## General help 

```
{%= partial("usage.md") %}
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
{%= include("author") %}

## License
{%= copyright() %}
{%= license() %}

***

{%= include("footer") %}
