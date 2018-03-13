#!/usr/bin/env bash 
set -e
path=liege.urban
branches=$(git -C $path branch -a|grep -v "^\\*"|grep -v HEAD|grep -v master|grep -v profiles|grep -v '  origin'|sed 's%.*remotes/origin/\(.*\)%\1%')
git -C $path reset HEAD
git -C $path clean -f -d
git -C $path reset --hard
git -C $path checkout master
git -C $path reset --hard
git -C $path clean -f -d
for branch in master; do
  echo "--- BRANCH: $branch ---"
  git -C $path checkout "$branch"
  sed -i 's%svn .*communesplone/\(Products.urban\|imio.pm.wsclient\|imio.pm.locales\|appy\|liege.urban\)/trunk/*%git https://github.com/IMIO/\1.git%g' $path/*.cfg
  sed -i 's%svn .*communesplone/\(Products.urban\|imio.pm.wsclient\|imio.pm.locales\|appy\|liege.urban\)/tags/\(.*\)%git https://github.com/IMIO/\1.git rev=\2%g' $path/*.cfg
  sed -i '/Products.CMFPlone = svn https:\/\/svn.plone.org\/svn\/plone\/Products.CMFPlone\/branches\/4.1\//d' $path/*.cfg
  git -C $path mv svn.ignore .gitignore || true
  echo "--- Changes to be commited ---"
  git --no-pager -C $path diff
  echo "--- Checking if remaining svn ---"
  grep -ri svn $path|grep -v '.git'|grep -v 'svn_global.sh'|grep -v '.*.txt'|grep -v 'svn.plone.org' || true
  echo "--- Commit changes ---"
  rm -fr $path/.git/hooks
  git -C $path ci --no-verify -a -m "Migrate SVN to GIT" -m "Change sources config to use git instead of svn. This commit has been automated using a script."
  git -C $path push origin "$branch"
  echo "--- Cleanup ---"
  git -C $path reset HEAD
  git -C $path reset --hard
  git -C $path clean -f -d
  read -r
  echo ""
  echo ""
  echo ""
done
