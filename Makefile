agda := $(wildcard src/*.lagda)
agdai := $(wildcard src/*.agdai)
markdown := $(subst src/,out/,$(subst .lagda,.md,$(agda)))

all: $(markdown)

out/%.md: src/%.lagda
	mkdir -p out
	agda2html --verbose --link-to-agda-stdlib --jekyll-root=out/ -i $< -o $@

# serve website using jekyll
serve:
	ruby -S bundle exec jekyll serve --no-watch --detach

# build website using jekyll
build: $(markdown)
	ruby -S bundle exec jekyll build

# build website using jekyll incrementally
build-incremental:
	ruby -S bundle exec jekyll build --incremental

# remove all auxiliary files
clean:
ifneq ($(strip $(agdai)),)
	rm $(agdai)
endif

# remove all generated files
clobber: clean
	ruby -S bundle exec jekyll clean
ifneq ($(strip $(markdown)),)
	rm $(markdown)
endif
	rmdir out/

# install bundler, and gem dependencies
macos-setup:
	brew install libxml2
	ruby -S gem install bundler --no-ri --no-rdoc
	ruby -S gem install pkg-config --no-ri --no-rdoc -v "~> 1.1"
	ruby -S bundle config build.nokogiri --use-system-libraries
	ruby -S bundle install

# install agda, agda-stdlib, and agda2html
travis-setup:\
	$(HOME)/agda-master/\
	$(HOME)/agda-stdlib-master/\
	$(HOME)/agda2html-master/

$(HOME)/agda-master/:
	curl -L https://github.com/agda/agda/archive/master.zip -o $(HOME)/agda-master.zip
	unzip -qq $(HOME)/agda-master.zip -d $(HOME)
	cd $(HOME)/agda-master;\
		stack install --stack-yaml=stack-8.2.2.yaml

$(HOME)/agda-stdlib-master/:
	curl -L https://github.com/agda/agda-stdlib/archive/master.zip -o $(HOME)/agda-stdlib-master.zip
	unzip -qq $(HOME)/agda-stdlib-master.zip -d $(HOME)
	mkdir $(HOME)/.agda
	echo "standard-library" > $(HOME)/.agda/defaults
	echo "$(HOME)/agda-stdlib-master/standard-library.agda-lib" > $(HOME)/.agda/libraries

$(HOME)/agda2html-master/:
	curl -L https://github.com/wenkokke/agda2html/archive/master.zip -o $(HOME)/agda2html-master.zip
	unzip -qq $(HOME)/agda2html-master.zip -d $(HOME)
	cd $(HOME)/agda2html-master;\
		stack install

.phony: serve build clean clobber macos-setup travis-setup
