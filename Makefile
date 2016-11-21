DR := docker run -it --rm -w /code -v $$PWD:/code:rw jekyll/jekyll

build:
	${DR} jekyll build

shell:
	${DR} bash

cmd_%:
	${DR} $*

jcmd_%:
	${DR} jekyll $*
