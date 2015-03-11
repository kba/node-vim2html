Async = require 'async'
test = require 'tapes'

vim2html = require '../src'

DEBUG=false
# DEBUG=true

testFunc = (t) ->
	opts = {
		syntax: 'coffee'
		colorscheme: 'jellybeans'
		number_lines: 0
		use_css: 0
		pre_only: 1
	}
	# highlight some string
	vim2html.highlightString "var x={() ==> ERRo'neous';function <3", '/tmp/fpoo', opts, (err, data) ->
		t.notOk err
		t.ok data
		# console.log data
	# highlight this file
	vim2html.highlightFile __filename, null, opts, (err, data) ->
		t.notOk err
		t.ok data
		# console.log data
	t.end()

test "Basic async each test", testFunc

# ALT: src/index.coffee
