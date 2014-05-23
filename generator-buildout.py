#! /usr/bin/python
import sys
f = sys.argv[1]
template = """
create repository %(repo_name)s
end repository

match /%(path)s/(%(repo_with_re)s)/trunk/
    repository %(repo_name)s
    branch master
end match

match /%(path)s/(%(repo_with_re)s)/tags/([^/]+)/
    repository %(repo_name)s
    branch \\2
end match
"""

path = f.split('.')[:-1]
path = '/'.join(path)
with open(f, 'r') as fd:
    for p in fd.readlines():
        repo = p.strip()
        repo = repo.strip('/')
        repo_name = repo
        repo_with_re = repo.replace('.', '\.')
        print template % {'repo_name': repo_name,
                          'repo_with_re': repo_with_re,
                          'path': path}
