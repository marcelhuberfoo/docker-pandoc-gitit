# pandoc-gitit
[Docker](https://www.docker.io/) container for [Pandoc](http://johnmacfarlane.net/pandoc)
and [Gitit](http://gitit.net/), with Latex tools installed for pdf creation.

## Purpose

This docker image builds on top of marcelhuberfoo/cabal-build image for the purpose of building
`pandoc` and `gitit` using cabal. It provides several key features:

* A non-root user (`user`) for executing the image build and running either `pandoc` or `gitit`.
* Access to data files, either files to convert or your Wiki contents, will be located in the volume at `/data`.
  This directory will be the default working directory and should have user/group write permissions set to work.

## Usage

### `pandoc`

Supported conversion formats can be retrieved by executing the container without arguments. It will default 
execute `pandoc --help`.

```
docker run --rm marcelhuberfoo/pandoc-gitit

pandoc [OPTIONS] [FILES]
Input formats:  docbook, haddock, html, json, latex, markdown, markdown_github,
                markdown_mmd, markdown_phpextra, markdown_strict, mediawiki,
                native, opml, rst, textile
Output formats: asciidoc, beamer, context, docbook, docx, dzslides, epub, epub3,
                fb2, html, html5, json, latex, man, markdown, markdown_github,
                markdown_mmd, markdown_phpextra, markdown_strict, mediawiki,
                native, odt, opendocument, opml, org, pdf*, plain, revealjs,
                rst, rtf, s5, slideous, slidy, texinfo, textile
                [*for pdf output, use latex or beamer and -o FILENAME.pdf
```
The following command shows the use of a mapped volume containing the input and output files for conversion:

```
docker run -v /tmp/my-data:/data marcelhuberfoo/pandoc-gitit pandoc -f markdown -t html5 myfile.md -o myfile.html
```


### `gitit`

For a first exploration, if you don't already use Gitit or don't map a volume:

```bash
docker run -d --name gitit \
      -e GIT_COMMITTER_NAME="User Name" \
      -e GIT_COMMITTER_EMAIL="user@domain.com" \
      -p 60000:5001 \
      marcelhuberfoo/pandoc-gitit
```

***It is important to pass in the committers name and email at least for the first commits of gitit!***
Otherwise the container will abort due to `git commit` errors. As soon as you created a user and logged in,
the commit author is the user name.
Default author name is **Gitit** and author email is empty.
If you like to set these values explicitly, add them to the list of environment variables to pass in
(exchange `COMMITTER` with `AUTHOR`).


To use an existing Gitit wiki (assuming it's installed at /home/gitit/wiki), mount it as a volume :

```bash
docker run -d --name gitit \
      -e GIT_COMMITTER_NAME="User Name" \
      -e GIT_COMMITTER_EMAIL="user@domain.com" \
      -p 60000:5001 \
      -v /home/gitit/wiki:/data \
      marcelhuberfoo/pandoc-gitit
```

Instead of passing in the committer and user name as environment variables, set it in your `.git/config`
administrative file from within the mounted volume.
E.g. `git --git-dir=/home/gitit/wiki/wikidata/.git config user.name "Some User"` and
`git --git-dir=/home/gitit/wiki/wikidata/.git config user.email "user@domain.com"` respectively.
You can do it likewise for the author.

`/data/gitit.conf` should contain the configuration file for gitit.
If you don't provide it, a default one will be created.

Gitit will also create the following folders when started for the first time:

- `/data/static/` contains static (css and img) files used by gitit.
- `/data/templates/` contains HStringTemplate templates for wiki pages.
- `/data/wikidata/` contains the Git repo where all pages are stored.

**Exposed Ports**

- 5001, Gitit default webserver port

## Permissions
This image uses `user` to run `pandoc` and `gitit`. This means that your file permissions
must allow this user to write to the mapped volume. The user has a `UID` of `1000` and a `GID` of `100`
which is equal to the initial `user` and `users` group on most Linux systems. You have to ensure that
such a `UID:GID` combination is allowed to write to your mapped volume. The easiest way is to add
group write permissions for the mapped volume and change the group id of the volume to 100.

```bash
# Give permissions to the mapped volume:
chmod -R g+w /tmp/my-data
chgrp -R 100 /tmp/my-data
```
