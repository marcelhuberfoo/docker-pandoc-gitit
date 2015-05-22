# pandoc-gitit
[Docker][docker] container for [Pandoc][pandoc]
and [Gitit][gitit], with Latex tools installed for pdf creation.

## Purpose

This docker image builds on top of [marcelhuberfoo/cabal-build][dockercabal] image for the purpose of building
`pandoc` and `gitit` using [Cabal][cabal]. It provides several features of which some are already present in the base image:

* A non-root user and group `docky` for executing programs inside the container.
* A umask of 0002 for user `docky`.
* Exported variables `UNAME`, `GNAME`, `UID` and `GID` to make use of the user settings from within scripts.
* Timezone (`/etc/localtime`) is linked to `Europe/Zurich`, adjust if required in a derived image.
* An external build source folder can be mapped to the volume `/data`. This volume will be the default working directory.
* The [Cabal][cabal] bin directory (`/home/docky/.cabal/bin`) is automatically prepended to the `PATH` variable.

## Usage

### pandoc

Supported conversion formats can be retrieved by executing the container without arguments. It will default 
execute `pandoc --help`.

```
docker run --rm marcelhuberfoo/pandoc-gitit

pandoc [OPTIONS] [FILES]
Input formats:  docbook, docx, epub, haddock, html, json, latex, markdown,
                markdown_github, markdown_mmd, markdown_phpextra,
                markdown_strict, mediawiki, native, opml, org, rst, t2t,
                textile, twiki
Output formats: asciidoc, beamer, context, docbook, docx, dokuwiki, dzslides,
                epub, epub3, fb2, haddock, html, html5, icml, json, latex, man,
                markdown, markdown_github, markdown_mmd, markdown_phpextra,
                markdown_strict, mediawiki, native, odt, opendocument, opml,
                org, pdf*, plain, revealjs, rst, rtf, s5, slideous, slidy,
                texinfo, textile
                [*for pdf output, use latex or beamer and -o FILENAME.pdf]
Options:
...
```
The following command shows the use of a mapped volume containing the input and output files for conversion:

```
docker run -v /tmp/my-data:/data marcelhuberfoo/pandoc-gitit pandoc -f markdown -t html5 myfile.md -o myfile.html
```


### gitit

For a first exploration, if you don't already use Gitit or don't map in a volume:

```bash
docker run -d --name gitit \
      -e GIT_COMMITTER_NAME="User Name" \
      -e GIT_COMMITTER_EMAIL="user@domain.com" \
      -p 60000:5001 \
      marcelhuberfoo/pandoc-gitit
```

***It is important to pass in the committers name and email at least for the first commits of gitit!***
Otherwise the container will abort due to `git commit` errors. As soon as you created a user and logged in,
the commit author is the user name. Default author name is **Gitit** and author email is empty.

If you like to set these values explicitly, add them to the list of environment variables to pass in
(exchange `COMMITTER` with `AUTHOR`).

Instead of passing in the committer and user name as environment variables, set it in your `.git/config`
administrative file from within the mounted volume.
E.g. `git --git-dir=/home/gitit/wiki/wikidata/.git config user.name "Some User"` and
`git --git-dir=/home/gitit/wiki/wikidata/.git config user.email "user@domain.com"` respectively.
You can do it likewise for the author.

To use an existing Gitit wiki (assuming it's installed at /home/gitit/wiki), mount it as a volume :

```bash
docker run -d --name gitit \
      -e GIT_COMMITTER_NAME="User Name" \
      -e GIT_COMMITTER_EMAIL="user@domain.com" \
      -p 60000:5001 \
      -v /home/gitit/wiki:/data \
      marcelhuberfoo/pandoc-gitit
```

#### files and folders

`/data/gitit.conf` should contain the configuration file for gitit.
If you don't provide it, a default one will be created.

Gitit will also create the following folders when started for the first time:

- `/data/static/` contains static (css and img) files used by gitit.
- `/data/templates/` contains HStringTemplate templates for wiki pages.
- `/data/wikidata/` contains the Git repo where all pages are stored.

#### Exposed Ports

**5001:** Gitit default webserver port

## Permissions

This image provides a user and group `docky` to run `pandoc` or `gitit` as user `docky`.

If you map in the `/data` volume, permissions on the host folder must allow user or group `docky` to write to it. I recommend adding at least a group `docky` with GID of `654321` to your host system and change the group of the folder to `docky`. Don't forget to add yourself to the `docky` group.
The user `docky` has a `UID` of `654321` and a `GID` of `654321` which should not interfere with existing ids on regular Linux systems.

Add user and group docky, group might be sufficient:
```bash
groupadd -g 654321 docky
useradd --system --uid 654321 --gid docky --shell '/sbin/nologin' docky
```

Add yourself to the docky group:
```bash
gpasswd --add myself docky
```

Set group permissions to the entire project directory:
```bash
chmod -R g+w /tmp/my-data
chgrp -R docky /tmp/my-data
```

[cabal]: https://haskell.org/haskellwiki/Cabal
[docker]: https://www.docker.io/
[pandoc]: http://johnmacfarlane.net/pandoc
[gitit]: http://gitit.net/
[dockercabal]: https://registry.hub.docker.com/u/marcelhuberfoo/cabal-build/
