SVN Migration to Git
====================

Fetch/Update svn repo locally:

  make checkout

Generate the rules using:

  make rules

Generate git repos using:

  make migrate

Extract authors:

  make authors

Generate git repos, create all repos on github, set origin to github and push:

  make push
