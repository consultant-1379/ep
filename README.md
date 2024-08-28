# 5G CI/CD system Enhancement Proposals (EPs)

The repository 5gcicd/ep is intended to hold Enhancement Proposals to the 5G CI/CD system.

Since Gerrit lacks a clean ChatOps interface of the likes of GitHub or GitLab,
we'll use Gerrit patch-sets and the Gerrit review process to manage EPs.

If this process doesn't work, we'll consider other alternatives like e.g. the
corporate GitLab CE beta service (https://gitlab.rnd.gic.ericsson.se/).

## What is an EP?

An EP is any suggestion you may have to improve the 5G CI/CD system, either for your
own project or for all users.

EPs shall be documented in plain text or ReST representation.

Any EP should be self-contained, it must describe the proposal and include any links
to information useful to understand it. The EP shall not require asking for additional
information or face-to-face contact in order to manage it.

## The EP submission process

To submit an EP, follow these steps:

1) Clone the EP repository

```console
$ git clone ssh://<signum>@gerrit.ericsson.se:29418/5gcicd/ep
```

2) Check the directories under 'documentation' in the repository

```console
$ ls -l --group-directories-first documentation/
```

3) Note the last directory in the listing, and create a new directory
   which name ends in a number higher than that last directory. For
   example, if the last directory is 'EP-122':

```console
$ mkdir documentation/EP-123
```

4) Store the documents describing your EP under the directory just created.
   If you use ReST format (files with .rst extension), you will get you EP
   automatically verified by the CI/CD Jenkins system.

5) Submit your EP as a patch-set to Gerrit:

```console
$ git add documentation/EP-123
$ git commit -m "EP-123"
$ git pull --rebase
$ git push origin HEAD:refs/for/master%topic=EP-123
```

## The EP review process

Your EP will be reviewed by the CI/CD team, and comments will be posted to the change.
Using the Gerrit UI, you can check, answer, and solve comments.
If you make any changes to your EP as a consequence of the comments received,
push a new patch-set to Gerrit:

```console
$ git add documentation/EP-123/make-cicd-awesome.txt
$ git commit --amend
$ git pull --rebase
$ git push origin HEAD:refs/for/master
```

The review cycle starts again until content is agreed. Then the EP will be merged
into the '5gcicd/ep' repository and the enhancement added to the CI/CD team's
backlog.

