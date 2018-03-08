all-no-push: cleanup sync-svn checkout migrate-test migrate create-all-repos-on-github set-origin

all: all-no-push push-all


init:
	git submodule update --init
	git clone https://github.com/svn-all-fast-export/svn2git
	sudo apt-get install -y build-essential subversion git qtchooser qt5-default libapr1 libapr1-dev libsvn-dev
	cd svn2git/ && qmake && make
	virtualenv .
	cd imio.github && ../bin/python setup.py install

cleanup: 
	rm -f log* rules.* *\.repos *.log
	touch repos
	for r in `cat repos`; do rm -vfr $$r;done;
	rm repos

generate-rules: cleanup checkout
	svn ls imio-svn/svn-root2-checkout/communesplone/ | grep -v buildout | grep -v -f ignore > communesplone.repos
	svn ls imio-svn/svn-root2-checkout/communesplone/buildout/ | grep -v -f ignore > communesplone.buildout.repos
	sed -i 's/\$$//g' communesplone.repos communesplone.buildout.repos
	./generator.py communesplone.repos > rules.root
	./generator-buildout.py communesplone.buildout.repos > rules.buildout

rules:
	cat rules.root > rules.all
	cat rules.buildout >> rules.all
	echo "match / \nend match" >> rules.all
	grep "create " rules.all|awk '{print $$3}' > repos

sync-svn:
	rsync -arv zope@devel.imio.be:/srv/subversion/svn-root2 imio-svn

checkout: sync-svn
	svn co --ignore-externals file:///$$PWD/imio-svn/svn-root2 $$PWD/imio-svn/svn-root2-checkout

migrate: rules
	svn2git/svn-all-fast-export --identity-map authors --rules rules.all $$PWD/imio-svn/svn-root2

authors: checkout
	cd $$PWD/imio-svn/svn-root2-checkout && svn log -q | grep -e '^r' | awk 'BEGIN { FS = "|" } ; { print $$2 }' | sort | uniq > ../../authors.raw
	sed -i 's/ \(.*\) /\1 = \1 <\1@imio.be>/g' authors.raw

migrate-test: rules
	svn2git/svn-all-fast-export --dry-run --identity-map authors --rules rules.all $$PWD/imio-svn/svn-root2

create-all-repos-on-github:
	bin/create_repos_from_file repos

set-origin:
	for repo in `cat repos` ; do \
	   cd $$repo; \
	   git remote add origin git@github.com:IMIO/$$repo.git; \
	   cd ..; \
	done

push: create-all-repos-on-github set-origin push-all

push-all:
	for repo in `cat repos` ; do \
	   cd $$repo; \
	   git push -u origin --mirror; \
	   cd ..; \
	done
