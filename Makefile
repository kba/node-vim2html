RAWGITHUB = https://raw.githubusercontent.com
WGET = wget --quiet
MKDIR = mkdir -p
CP = cp -rv

all: lib vim-rtp

lib:
	echo $(RAWGITHUB)
	coffee -o lib src

clean:
	rm -rf lib
	rm -rf vim-rtp

vim-rtp: vim-rtp/colors vim-rtp/syntax

vim-colorschemes:
	git submodule init
	git submodule update

vim-rtp/colors: vim-colorschemes
	$(MKDIR) vim-rtp
	$(CP) vim-colorschemes/colors vim-rtp

vim-rtp/syntax:
	$(MKDIR) vim-rtp/syntax
	cd vim-rtp/syntax && $(WGET) "$(RAWGITHUB)/kchmck/vim-coffee-script/master/syntax/coffee.vim"
	cd vim-rtp/syntax && $(WGET) "$(RAWGITHUB)/kba/turtleson.vim/master/syntax/turtleson.vim"
	cd vim-rtp/syntax && $(WGET) "$(RAWGITHUB)/neapel/vim-n3-syntax/master/syntax/n3.vim"
	cd vim-rtp/syntax && $(WGET) "$(RAWGITHUB)/elzr/vim-json/master/syntax/json.vim"
