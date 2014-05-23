all: cleanup sync-svn checkout migrate-test migrate create-all-repos-on-github set-origin push-all

install:
	virtualenv .
	cd imio.github && ../bin/python setup.py develop

cleanup:
	rm -f log*

sync-svn:
	rsync -arv zope@devel.imio.be:/srv/subversion/svn-root2 imio-svn

checkout:
	svn co --ignore-externals file:///$$PWD/imio-svn/svn-root2 $$PWD/imio-svn/svn-root2-checkout

migrate: cleanup
	for r in rules.*; do svn-all-fast-export --identity-map authors --rules $$r $$PWD/imio-svn/svn-root2;done;

authors: checkout
	cd $$PWD/imio-svn/svn-root2-checkout && svn log -q | grep -e '^r' | awk 'BEGIN { FS = "|" } ; { print $$2 }' | sort | uniq > ../../authors.raw
	sed -i 's/ \(.*\) /\1 = \1 <\1@imio.be>/g' authors.raw

migrate-test:
	for r in rules.*; do svn-all-fast-export --dry-run --identity-map authors --rules $$r $$PWD/imio-svn/svn-root2;done;

create-all-repos-on-github:
	grep "create " rules.*|awk '{print $$3}' > repos
	bin/create_repos_from_file repos

set-origin:
	for repo in `cat repos` ; do \
	   cd $$repo; \
	   git remote add origin git@github.com:IMIO/$$repo.git; \
	   cd ..; \
	done

push-all:
	for repo in `cat repos` ; do \
	   cd $$repo; \
	   git push -u origin --mirror; \
	   cd ..; \
	done
