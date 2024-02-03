## our_shell: ysh
## oils_failures_allowed: 0

#### ctx push and set
var mydict = {}
ctx push (mydict) {
  ctx set (key1="value1")
  ctx set (key2="value2")
}
json write (mydict)
## STDOUT:
{
  "key1": "value1",
  "key2": "value2"
}
## END

#### ctx emit
var p = {}
ctx push (p) {
  ctx emit flag ({short_name: '-v'})
  # p => {'flag': [{short_name: '-v'}]}
  json write (p)

  ctx emit flag ({short_name: '-c'})
  # p => {'flag': [{short_name: '-v'}, {short_name: '-c'}]}
  json write (p)
}
json write (p)
## STDOUT:
{
  "flag": [
    {
      "short_name": "-v"
    }
  ]
}
{
  "flag": [
    {
      "short_name": "-v"
    },
    {
      "short_name": "-c"
    }
  ]
}
{
  "flag": [
    {
      "short_name": "-v"
    },
    {
      "short_name": "-c"
    }
  ]
}
## END

#### mini-argparse
proc parser (; place ; ; block_def) {
  var p = {}
  ctx push (p, block_def)
  call place->setValue(p)
}

var Bool = "Bool"
var Int = "Int"
proc flag (short_name, long_name; type; help) {
  ctx emit flag ({short_name, long_name, type, help})
}

proc arg (name) {
  ctx emit arg ({name})
}

parser (&spec) {
  flag -t --tsv (Bool, help='Output as a TSV')
  flag -r --recursive (Bool, help='Recurse into the given directory')
  flag -N --count (Int, help='Process no more than N files')
  arg path
}
json write (spec)
## STDOUT:
{
  "flag": [
    {
      "short_name": "-t",
      "long_name": "--tsv",
      "type": "Bool",
      "help": "Output as a TSV"
    },
    {
      "short_name": "-r",
      "long_name": "--recursive",
      "type": "Bool",
      "help": "Recurse into the given directory"
    },
    {
      "short_name": "-N",
      "long_name": "--count",
      "type": "Int",
      "help": "Process no more than N files"
    }
  ],
  "arg": [
    {
      "name": "path"
    }
  ]
}
## END
