vim2html
====================

[![Build Status](https://travis-ci.org/kba/node-vim2html.svg?branch=master)](https://travis-ci.org/kba/node-vim2html)

Create syntax-highlighted HTML from source code using Vim's 2html script

```coffee
vim2html = require 'vim2html'
opts = {
    syntax: 'coffee'
    colorscheme: 'jellybeans'
    number_lines: 0
    use_css: 0
    pre_only: 1
}

# highlight some string, write result to result.html
vim2html.highlightString "var x={() ==> ERRo'neous';function <3", 'result.html', opts, (err, asFilename) -> ...

# highlight the file containing the following statement
vim2html.highlightFile __filename, null, opts, (err, asString) -> ...
```
