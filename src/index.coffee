### 
# Some Module

###
Temp         = require 'temp'
Merge        = require 'merge'
Mv			 = require 'mv'
Fs           = require 'fs'
ChildProcess = require 'child_process'

Temp.track()

_vimBundleBase = "#{__dirname}/../vim-bundle"
vimRuntimePaths = Fs.readdirSync(_vimBundleBase).map (val) -> "#{_vimBundleBase}/#{val}"

class Vim2HTML

	_defaultOpts : {
		vimExecutable: '/usr/bin/vim'
		syntax: 'c'
		colorscheme: 'delek'
	}

	highlightFile : (inputFile, outputFile, opts, cb) ->
		if typeof outputFile is 'function'
			[cb, outputFile, opts] = [outputFile, inputFile, {}]
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
			if outputFile
				if outputFile is '-'
					Fs.readFile tempOutFile, (err, data) ->
						return cb err if err
						return cb null, data.toString()
				else
					Mv tempOutFile, outputFile, (err) ->
						return cb err if err
						return cb null, outputFile
			else 
				return cb null, tempOutFile


	# runs vim returns a callback with the path to the output file
	_run_vim: (inputFile, opts, cb) ->
		# console.log cb.toString()

		tempOutFile = Temp.path {
			prefix: 'node-vim2html_'
			suffix: '.html'
		}
		cmdArgs = [
			"-E"	# Extended Ex mode
			"-s"	# silent
		]
		vimCommands = []
		for rtp in vimRuntimePaths
			vimCommands.push "set rtp^=#{rtp}"
		vimCommands.push cmd for cmd in [
			"set t_Co=256"
			"syntax on"
			"let g:html_no_progress=1"
			"set syntax=#{opts.syntax}"
			"colorscheme #{opts.colorscheme}"
			"TOhtml"
			"saveas! #{tempOutFile}"
			"qall" # TODO server mode ?
		]
		for vimCommand in vimCommands
			cmdArgs.push "-c"
			cmdArgs.push vimCommand
		cmdArgs.push '--'
		cmdArgs.push inputFile

		vim = ChildProcess.spawn(opts.vimExecutable, cmdArgs)
		vim.on 'error', (err) -> 
			return cb new Error('Could not spawn vim process')

		# When vim finished without error, read back the html and return it
		vim.on 'close', (code) ->
			if code not in [0, 1]
				return cb new Error( "Vim failed to convert #{inputFile} [Code: #{code}]")
			return cb null, tempOutFile

module.exports = new Vim2HTML()

# ALT: test/test.coffee
