#!/usr/bin/env bash
set -euxo pipefail
path=$1
branches=$(git -C "$path" branch -a | grep -v "^\\*" | grep -v HEAD | grep -v " master" | grep -v profiles | grep -v '  origin' | sed 's%.*remotes/origin/\(.*\)%\1%')
git -C "$path" reset HEAD
git -C "$path" clean -f -d
git -C "$path" reset --hard
git -C "$path" checkout master
git -C "$path" reset --hard
git -C "$path" clean -f -d
#for branch in master; do
for branch in "3.0"; do
	echo "--- BRANCH: $branch ---"
	git -C "$path" checkout "$branch"
	if [[ $path != "clone/buildout.pm" && $path != "clone/imio.pm.ws" && $path != "clone/imio.pm.wsclient" ]]; then
		find "$path" ! -name 'setup.cfg' -name '*.cfg' -printf '%P\n' | xargs -r git -C "$path" rm
		find "$path" ! -name 'generate.conf' -name '*.conf' -printf '%P\n' | xargs -r git -C "$path" rm
		test -f "$path/bootstrap.py" && git -C "$path" rm bootstrap.py
		test -f "$path/Makefile" && git -C "$path" rm Makefile
	fi
	find "$path" -name "*.cfg" -exec sed -i 's%communesplone.iconified_document_actions%collective.iconifieddocumentactions%g' {} \;
	find "$path" -name "*.cfg" -exec sed -i 's%svn .*communesplone/\(imio.actionspanel\|plonetheme.imioapps\|Products.MeetingNamur\|Products.MeetingLalouviere\|Products.MeetingCommunes\|imio.migrator\|communesplone.layout\|Products.PloneMeeting\|imio.pm.ws\|imio.pm.wsclient\|ZSI\|communesplone.layout\|plonetheme.imioapps\|imio.pm.locales\|imio.pm.ws\|imio.migrator\|imio.actionspanel\|collective.iconifieddocumentactions\)/trunk/*%git https://github.com/IMIO/\1.git%g' {} \;
	find "$path" -name "*.cfg" -exec sed -i 's%svn .*communesplone/\(imio.actionspanel\|plonetheme.imioapps\|Products.MeetingNamur\|Products.MeetingLalouviere\|Products.MeetingCommunes\|imio.migrator\|communesplone.layout\|Products.PloneMeeting\|imio.pm.ws\|imio.pm.wsclient\|imio.pm.locales\|collective.iconifieddocumentactions\)/tags/\(.*\)%git https://github.com/IMIO/\1.git rev=\2%g' {} \;
	find "$path" -name "*.cfg" -exec sed -i 's%svn .*communesplone/\(imio.actionspanel\|plonetheme.imioapps\|Products.MeetingNamur\|Products.MeetingLalouviere\|Products.MeetingCommunes\|imio.migrator\|communesplone.layout\|Products.PloneMeeting\|imio.pm.ws\|imio.pm.wsclient\|imio.pm.locales\|collective.iconifieddocumentactions\)/branches/\(.*\)%git https://github.com/IMIO/\1.git branch=\2%g' {} \;
	find "$path" -name "*.cfg" -exec sed -i '/communesplone\/appy/d' {} \;
	git -C "$path" mv svn.ignore .gitignore || true
	echo "--- Changes to be commited ---"
	git --no-pager -C "$path" diff
	echo "--- Checking if remaining svn ---"
	grep -Iri svn "$path" | grep -v '.git' | grep -v 'svn_global.sh' | grep -iv '.*.txt' | grep -v 'svn.plone.org' | grep -v zip.py | grep -v .eml: | grep -v zopesvn | grep -v svnproducts | grep -v MANIFEST.in | grep -v RELEASE | grep -v tag_svn_revision || true
	echo "--- Commit changes ---"
	rm -fr "$path/.git/hooks"
	git diff-index --quiet HEAD || git -C "$path" ci --no-verify -a -m "Migrate SVN to GIT" -m "Change sources config to use git instead of svn. This commit has been automated using a script."
	git -C "$path" push origin "$branch"
	echo "--- Cleanup ---"
	git -C "$path" reset HEAD
	git -C "$path" reset --hard
	git -C "$path" clean -f -d
	read -r
	echo ""
	echo ""
	echo ""
done
