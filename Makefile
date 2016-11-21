DR := docker run -it --rm -w /code -v $$PWD:/code:rw jekyll/jekyll

build:
	${DR} jekyll build

serve:
	docker run --name jekyll_serve -d -p 127.0.0.1:4000:4000 -w /code -v $$PWD:/code:rw jekyll/jekyll jekyll serve

shell:
	${DR} bash

cmd_%:
	${DR} $*

jcmd_%:
	${DR} jekyll $*
