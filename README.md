SVN Migration to Git
====================

Fetch/Update svn repo locally:

``` sh
  make checkout
```

Generate the rules using:

``` sh
  make rules
```

Generate git repos using:

``` sh
  make migrate
```

Extract authors:

``` sh
  make authors
```

Generate git repos, create all repos on github, set origin to github and push:

``` sh
  make push
```
