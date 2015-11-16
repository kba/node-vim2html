
all: lib vim-rtp

lib:
	coffee -o lib src

clean:
	rm -rf lib
	rm -rf vim-rtp

vim-rtp:
	bash setup-vim-rtp.sh
