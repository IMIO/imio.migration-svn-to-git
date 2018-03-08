SVN Migration to Git
====================

Initialisation:

``` sh
   make init
```

Fetch/Update svn repo locally:

``` sh
  make checkout
```

Generate the rules using:

``` sh
  make generate-rules
```

Edit rules.root and rules.buildout to select repositories that you want to migrate

Concat the rules using:

``` sh
  make rules
```

Extract authors and create authors.raw file:

``` sh
  make authors
```

Based on user present in authors.raw edit the users that you want to keep in authors

Test your migration using migrate-test step:

``` sh
  make migrate-test
```

Generate git repos using:

``` sh
  make migrate
```

Generate git repos, create all repos on github, set origin to github and push:

``` sh
  make push
```
