---
in_progress: yes
---

Process Model
=============

Related: [Interpreter State](interpreter-state.html).  These two docs are the
missing documentation for shell!


<div id="toc">
</div>

## Constructs


### Pipelines

- `shopt -s lastpipe`

### Functions Can Be Transparently Put in Pipelines


### Explicit Subshells are Rarely Needed

- prefer `pushd` / `popd`, or `cd { }` in YSH.

### Redirects


### Other

- xargs, xargs -P
- find -exec

<!-- See [Unix Tools] on the wiki. -->

## Builtins

### [wait]($help)

### [fg]($help)

### [bg]($help)

### [trap]($help)



