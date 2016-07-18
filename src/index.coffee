###
# Some Module

###
Temp         = require 'temp'
Merge        = require 'merge'
Mv			 = require 'mv'
Fs           = require 'fs'
ChildProcess = require 'child_process'

class Vim2HTML

	_defaultOpts : {
		# Vim executable
		vimExecutable: '/usr/bin/vim'
		# Syntax to use
		syntax: 'c'
		# Colorscheme to use
		colorscheme: 'delek'
		# g:html_ignore_folding
		ignore_folding: 1
		# g:html_ignore_conceal
		ignore_conceal: 1
		# g:html_use_css
		use_css: 1
		# g:html_number_lines
		number_lines: 1
		# return <pre> only?
		pre_only: 0
		# Tabstop
		tabstop: 4
	}

	highlightString : (inputString, outputFile, opts, cb) ->
		self = @
		Temp.open 'node-vim2html', (err, info) ->
			return cb err if err
			Fs.writeFile info.path, inputString, (err) ->
				return cb err if err
				return self.highlightFile(info.path, outputFile, opts, cb)

	highlightFile : (inputFile, outputFile, opts, cb) ->
		if typeof outputFile is 'function'
			[cb, outputFile, opts] = [outputFile, null, {}]
		if typeof opts is 'function'
			cb = opts
			if typeof outputFile is 'string'
				opts = {}
			else
				opts = outputFile
				outputFile = null
		if not cb then throw new Error("Must provide callback to #convertFile")
		opts = Merge(@_defaultOpts, opts)
		@_run_vim inputFile, opts, (err, tempOutFile) ->
			return cb err if err
			if not outputFile
				Fs.readFile tempOutFile, (err, data) ->
					return cb err if err
					return cb null, data.toString()
			else
				Mv tempOutFile, outputFile, (err) ->
					return cb err if err
					return cb null, outputFile


	# runs vim returns a callback with the path to the output file
	_run_vim: (inputFile, opts, cb) ->
		# console.log cb.toString()
		reduceCommands = []
		if opts.pre_only
			_openPre='<pre'
			_closePre='<\\/pre>'
			if opts.use_css
				# Delete from start-of-file to the first <pre
				reduceCommands.push "%s/\\%^\\_.*#{_openPre}/#{_openPre}/"
			else
				# Replace those pesky linebreaks
				reduceCommands.push "%s/<br>//"
				# Replace this with a pre, take bgcolor and textcolor from body
				search='<body bgcolor="\\([^"]\\+\\)" text="\\([^"]\\+\\)"\\_.*<font face="monospace">'
				replace='<pre style="color: \\2; background-color: \\1">'
				reduceCommands.push "%s/\\%^\\_.*#{search}/#{replace}/"
				# Search ^</font
				reduceCommands.push "%s/^<\\/font>/#{_closePre}/"
			# Search </pre
			reduceCommands.push "g/^#{_closePre}/"
			# Delete till end of file
			reduceCommands.push "+,$d"

		tempOutFile = Temp.path {
			prefix: 'node-vim2html_'
			suffix: '.html'
		}
		cmdArgs = [
			# "-E"	# Extended Ex mode
			# "-s"	# silent
		]
		cmdArgs.push "-c"
		cmdArgs.push [
			"set rtp^=#{__dirname}/../vim-rtp"
			"set t_Co=256"
			"syntax on"
			"set syntax=#{opts.syntax}"
			"colorscheme #{opts.colorscheme}"
			"set tabstop=#{opts.tabstop}"
			"let g:html_no_progress=1"
			"let g:html_ignore_folding=#{opts.ignore_folding}"
			"let g:html_ignore_conceal=#{opts.ignore_conceal}"
			"let g:html_use_css=#{opts.use_css}"
			"let g:html_number_lines=#{opts.number_lines}"
			"TOhtml"].join('|')
		if opts.pre_only
			cmdArgs.push "-c"
			cmdArgs.push reduceCommands.join("|")
		cmdArgs.push "-c"
		cmdArgs.push [
			"saveas! #{tempOutFile}"
			"qall" # TODO server mode ?
		].join("|")
		cmdArgs.push '--'
		cmdArgs.push inputFile

		# console.log "#{opts.vimExecutable} #{cmdArgs.map((v)->"'#{v}'").join(' ')}"
		vim = ChildProcess.spawn(opts.vimExecutable, cmdArgs)
		vim.on 'error', (err) ->
			return cb new Error('Could not spawn vim process')

		# When vim finished without error, read back the html and return it
		vim.on 'close', (code) ->
			if code not in [0, 1] #XXX this is a hack
				return cb new Error( "Vim failed to convert #{inputFile} [Code: #{code}]")
			return cb null, tempOutFile

module.exports = new Vim2HTML()

# ALT: test/test.coffee
