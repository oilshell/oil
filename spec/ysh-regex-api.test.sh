## oils_failures_allowed: 1

#### s ~ regex and s !~ regex
shopt -s ysh:upgrade

var s = 'foo'
if (s ~ '.([[:alpha:]]+)') {  # ERE syntax
  echo matches
  argv.py $[_match(0)] $[_match(1)]
}
if (s !~ '[[:digit:]]+') {
  echo "does not match"
  argv.py $[_match(0)] $[_match(1)]
}

if (s ~ '[[:digit:]]+') {
  echo "matches"
}
# Should be cleared now
# should this be Undef rather than ''?
try {
  var x = _match(0)
}
if (_status === 2) {
  echo 'got expected status 2'
}

try {
  var y = _match(1)
}
if (_status === 2) {
  echo 'got expected status 2'
}

## STDOUT:
matches
['foo', 'oo']
does not match
['foo', 'oo']
got expected status 2
got expected status 2
## END

#### Eggex flags to ignore case are respected
shopt -s ysh:upgrade

# based on Python's spelling
var pat = / 'abc' ; i /
var pat2 = / @pat 'def' ; reg_icase /  # this is allowed

if ('-abcdef-' ~ pat2) {
  echo 'yes'
}

if ('-ABCDEF-' ~ pat2) {
  echo 'yes'
}

if ('ABCDE' ~ pat2) {
  echo 'BUG'
}

## STDOUT:
yes
yes
## END

#### Positional captures with _match
shopt -s ysh:all

var x = 'zz 2020-08-20'

if [[ $x =~ ([[:digit:]]+)-([[:digit:]]+) ]] {
  argv.py "${BASH_REMATCH[@]}"
}

# THIS IS A NO-OP.  The variable is SHADOWED by the special name.
# I think that's OK.
setvar BASH_REMATCH = :| reset |

if (x ~ /<capture d+> '-' <capture d+>/) {
  argv.py "${BASH_REMATCH[@]}"
  argv.py $[_match(0)] $[_match(1)] $[_match(2)]

  argv.py $[_match()]  # synonym for _match(0)

  # TODO: Also test _start() and _end()
}
## STDOUT:
['2020-08', '2020', '08']
['2020-08', '2020', '08']
['2020-08', '2020', '08']
['2020-08']
## END

#### _match() returns null when group doesn't match
shopt -s ysh:upgrade

var pat = / <capture 'a'> | <capture 'b'> /
if ('b' ~ pat) {
  echo "$[_match(1)] $[_match(2)]"
}
## STDOUT:
null b
## END

#### _start() and _end()
shopt -s ysh:upgrade

var s = 'foo123bar'
if (s ~ /digit+/) {
  echo start=$[_start()] end=$[_end()]
}
echo ---

if (s ~ / <capture [a-z]+> <capture digit+> /) {
  echo start=$[_start(1)] end=$[_end(1)]
  echo start=$[_start(2)] end=$[_end(2)]
}
echo ---

if (s ~ / <capture [a-z]+> | <capture digit+> /) {
  echo start=$[_start(1)] end=$[_end(1)]
  echo start=$[_start(2)] end=$[_end(2)]
}

## STDOUT:
start=3 end=6
---
start=0 end=3
start=3 end=6
---
start=0 end=3
start=-1 end=-1
## END

#### Str->search() method returns value.Match object

var s = '= hi5- bye6-'

var m = s => search(/ <capture [a-z]+ > <capture d+> '-' ; i /)
echo "g0 $[m => start(0)] $[m => end(0)] $[m => group(0)]"
echo "g1 $[m => start(1)] $[m => end(1)] $[m => group(1)]"
echo "g2 $[m => start(2)] $[m => end(2)] $[m => group(2)]"

echo ---

var pos = m => end(0)  # search from end position
var m = s => search(/ <capture [a-z]+ > <capture d+> '-' ; i /, pos=pos)
echo "g0 $[m => start(0)] $[m => end(0)] $[m => group(0)]"
echo "g1 $[m => start(1)] $[m => end(1)] $[m => group(1)]"
echo "g2 $[m => start(2)] $[m => end(2)] $[m => group(2)]"

## STDOUT:
g0 2 6 hi5-
g1 2 4 hi
g2 4 5 5
---
g0 7 12 bye6-
g1 7 10 bye
g2 10 11 6
## END

#### Str->search() only matches %start ^ when pos == 0

shopt -s ysh:upgrade

var anchored = / %start <capture d+> '-' /
var free = / <capture d+> '-' /

var s = '12-34-'

for pat in ([anchored, free]) {
  echo "pat=$pat"

  var pos = 0
  while (true) {
    var m = s => search(pat, pos=pos)
    if (not m) {
      break
    }
    echo $[m => group(0)]
    setvar pos = m => end(0)
  }

}

## STDOUT:
pat=^([[:digit:]]+)-
12-
pat=([[:digit:]]+)-
12-
34-
## END

#### Str->leftMatch() can implement lexer pattern

shopt -s ysh:upgrade

var lexer = / <capture d+> | <capture [a-z]+> | <capture s+> /
#echo $lexer

var s = 'ab 12'

# This isn't OK
#var s = 'ab + 12 - cd'

var pos = 0

while (true) {
  echo "pos=$pos"

  # TODO: use leftMatch()
  var m = s->search(lexer, pos=pos)
  if (not m) {
    break
  }
  # TODO: add groups()
  #var groups = [m => group(1), m => group(2), m => group(3)]
  #json write --pretty=F (groups)
  echo "$[m => group(1)]/$[m => group(2)]/$[m => group(3)]/"

  echo

  setvar pos = m => end(0)
}

## STDOUT:
pos=0
null/ab/null/

pos=2
null/null/ /

pos=3
12/null/null/

pos=5
## END


#### Named captures with _match
shopt -s ysh:all

var x = 'zz 2020-08-20'

if (x ~ /<capture d+ as year> '-' <capture d+ as month>/) {
  argv.py $[_match('year')] $[_match('month')]
}
## STDOUT:
['2020', '08']
## END

#### Named Capture Decays Without Name
shopt -s ysh:all
var pat = /<capture d+ as month>/
echo $pat

if ('123' ~ pat) {
  echo yes
}

## STDOUT:
([[:digit:]]+)
yes
## END

#### Can't splice eggex with different flags
shopt -s ysh:upgrade

var pat = / 'abc' ; i /
var pat2 = / @pat 'def' ; reg_icase /  # this is allowed

var pat3 = / @pat 'def' /
= pat3

## status: 1
## STDOUT:
## END

#### Eggex with translation preference has arbitrary flags
shopt -s ysh:upgrade

# TODO: can provide introspection so users can translate it?
# This is kind of a speculative corner of the language.

var pat = / d+ ; ignorecase ; PCRE /

# This uses ERE, as a test
if ('ab 12' ~ pat) {
  echo yes
}

## STDOUT:
yes
## END


#### Invalid sh operation on eggex
var pat = / d+ /
#pat[invalid]=1
pat[invalid]+=1
## status: 1
## stdout-json: ""

#### Long Python Example

# https://docs.python.org/3/reference/lexical_analysis.html#integer-literals

# integer      ::=  decinteger | bininteger | octinteger | hexinteger
# decinteger   ::=  nonzerodigit (["_"] digit)* | "0"+ (["_"] "0")*
# bininteger   ::=  "0" ("b" | "B") (["_"] bindigit)+
# octinteger   ::=  "0" ("o" | "O") (["_"] octdigit)+
# hexinteger   ::=  "0" ("x" | "X") (["_"] hexdigit)+
# nonzerodigit ::=  "1"..."9"
# digit        ::=  "0"..."9"
# bindigit     ::=  "0" | "1"
# octdigit     ::=  "0"..."7"
# hexdigit     ::=  digit | "a"..."f" | "A"..."F"

shopt -s ysh:all

const DecDigit = / [0-9] /
const BinDigit = / [0-1] /
const OctDigit = / [0-7] /
const HexDigit = / [0-9 a-f A-F] /  # note: not splicing Digit into character class

const DecInt   = / [1-9] ('_'? DecDigit)* | '0'+ ('_'? '0')* /
const BinInt   = / '0' [b B] ('_'? BinDigit)+ /
const OctInt   = / '0' [o O] ('_'? OctDigit)+ /
const HexInt   = / '0' [x X] ('_'? HexDigit)+ /

const Integer  = / %start (DecInt | BinInt | OctInt | HexInt) %end /

#echo $Integer

if (    '123'  ~ Integer) { echo 'Y' }
if (    'zzz' !~ Integer) { echo 'N' }

if ('123_000'  ~ Integer) { echo 'Y decimal' }
if ('000_123' !~ Integer) { echo 'N decimal' }

if (  '0b100'  ~ Integer) { echo 'Y binary' }
if (  '0b102' !~ Integer) { echo 'N binary' }

if (  '0o755'  ~ Integer) { echo 'Y octal' }
if (  '0o778' !~ Integer) { echo 'N octal' }

if (   '0xFF'  ~ Integer) { echo 'Y hex' }
if (   '0xFG' !~ Integer) { echo 'N hex' }

## STDOUT:
Y
N
Y decimal
N decimal
Y binary
N binary
Y octal
N octal
Y hex
N hex
## END

#### Regex in a loop (bug regression)

shopt --set ysh:all

var content = [ 1, 2 ]
var i = 0
while (i < len(content)) {
  var line = content[i]
  write $[content[i]]
  if (str(line) ~ / s* 'imports' s* '=' s* .* /) {
    exit
  }
  setvar i += 1
}

## STDOUT:
1
2
## END


#### Regex in a loop depending on var

shopt --set ysh:all

var lines = ['foo', 'bar']
for line in (lines) {
  write "line $line"

  # = / $line /

if ("x$line" ~ / dot @line /) {
  #if (line ~ / $line /) {
    write "matched $line"
  }
}

## STDOUT:
line foo
matched foo
line bar
matched bar
## END


#### Regex with [ (bug regression)
shopt --set ysh:all

if ('[' ~ / '[' /) {
  echo 'sq'
}

if ('[' ~ / [ '[' ] /) {
  echo 'char class'
}

# User-reported string
if ("a" ~ / s* 'imports' s* '=' s* '[' /) {
  echo "yes"
}

## STDOUT:
sq
char class
## END
