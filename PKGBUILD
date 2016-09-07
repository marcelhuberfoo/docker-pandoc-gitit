# Contributor: Joop Kiefte <ikojba@gmail.com>
# Maintainer: Marcel Huber <`echo "moc tknup liamg tä oofrebuhlecram" | rev`>

pkgname=gitit
pkgver=0.12.1.1.8.gfe50da5
pkgrel=1
pkgdesc="Wiki using happstack, git or darcs, and pandoc."
url="https://github.com/jgm/gitit"
license=('GPL')
arch=('i686' 'x86_64')
depends=()
makedepends=(ghc cabal-install parallel)
optdepends=('texlive-most: for pdf creation')
#source=("$pkgname"::"git+https://github.com/jgm/gitit.git#tag=$pkgver")
source=("$pkgname"::"git+https://github.com/jgm/gitit.git")
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/$pkgname" 2>/dev/null && (
  if GITTAG="$(git describe --abbrev=0 --tags 2>/dev/null)"; then
    local _revs_ahead_tag=$(git rev-list --count ${GITTAG}..)
    local _commit_id_short=$(git log -1 --format=%h)
    echo $(sed -e s/^${pkgname%%-git}// -e 's/^[-_/a-zA-Z]\+//' -e 's/[-_+]/./g' <<< ${GITTAG}).${_revs_ahead_tag}.g${_commit_id_short}
  else
    echo 0.$(git rev-list --count master).g$(git log -1 --format=%h)
  fi
  ) || echo $pkgver
}

_cabal_verbose="--verbose=1"
_builddir=
_cabalsandboxdir=
_cabalsandboxbindir=
_cabal_buildflags_common="--enable-executable-stripping --disable-executable-dynamic --disable-debug-info"

_setupLocalEnvVars() {
  _builddir=$srcdir
  # use another subdir for sandbox to not disturb regular build
  _cabalsandboxfile=$_builddir/sandbox/cabal.sandbox.config
  _cabalsandboxdir=$_builddir/sandbox/.cabal-sandbox-$pkgname
  _cabalsandboxbindir=$_cabalsandboxdir/bin
  mkdir -p $_cabalsandboxdir
  export PATH=$_cabalsandboxbindir:$PATH
}

_prepareSandbox() {
  msg2 "Preparing sandbox"
  local _sandboxbase=$(dirname $_cabalsandboxdir)
  pushd "$_sandboxbase" >/dev/null
  cabal sandbox --sandbox=$_cabalsandboxdir init
  cabal --require-sandbox update >/dev/null
  popd >/dev/null
}

_installIntoSandbox() {
  local _installoptions="$1"
  shift
  local _basedir="$1"
  shift
  local _packages=$@
  msg2 "Installing package [$_packages] from dir [$(basename $_basedir)] into sandbox with options [$_installoptions]"
  pushd "$_basedir" >/dev/null
  cabal --require-sandbox --sandbox-config-file=$_cabalsandboxfile install \
    $_cabal_buildflags_common $_installoptions \
    $_packages
  popd >/dev/null
}

prepare() {
  cd "$srcdir/$pkgname"
  _setupLocalEnvVars
  _prepareSandbox
  _installIntoSandbox "" "." happy alex cpphs hsb2hs text-icu
  msg2 "Downloading/Extracting packages"
  parallel --no-notice --no-run-if-empty --bar "cd $_builddir && cabal --require-sandbox fetch --no-dependencies {}>/dev/null; find ~ -name {}-[0-9.]*.tar.gz -exec tar xzf \{\} --transform 's|^{}[^/]*|{}|' --show-transformed-names \;" ::: pandoc pandoc-citeproc
}

# arg1: configure options
# arg2: package
_buildPackageWithOpts() {
  local _installoptions="$1"
  local _flags="$2"
  local _hpkg=$3
  if [ ! -d "$_builddir/$_hpkg" ]; then echo "Package $_hpkg not found, skipping"; return; fi
  msg2 "Configuring package $_hpkg with flags [$_flags]"
  pushd $_builddir/$_hpkg >/dev/null
  cabal --require-sandbox --sandbox-config-file=$_cabalsandboxfile configure \
    $_installoptions \
    --flags="$_flags" \
    --prefix=/usr
  msg2 "Building package $_hpkg"
  cabal --require-sandbox --sandbox-config-file=$_cabalsandboxfile build
  cabal --require-sandbox --sandbox-config-file=$_cabalsandboxfile register --inplace
  popd >/dev/null
}

build() {
  _setupLocalEnvVars
  _installIntoSandbox "--dependencies-only" "$_builddir/pandoc" .
  _buildPackageWithOpts "$_cabal_buildflags_common" "" pandoc
  _installIntoSandbox "--dependencies-only" "$_builddir/pandoc-citeproc" .
  _buildPackageWithOpts "$_cabal_buildflags_common" "embed_data_files bibutils unicode_collation" pandoc-citeproc
  _installIntoSandbox "--dependencies-only" "$_builddir/gitit" .
  _buildPackageWithOpts "$_cabal_buildflags_common" "embed_data_files plugins" gitit
}

_installToPkgdir() {
  local _hpkg=$1
  local _licensedstdir=$pkgdir/usr/share/licenses/$_hpkg
  if [ ! -d "$_builddir/$_hpkg" ]; then echo "Package $_hpkg not found, skipping"; return; fi
  msg2 "Installing package $_hpkg"
  pushd $_builddir/$_hpkg >/dev/null
  cabal --require-sandbox --sandbox-config-file=$_cabalsandboxfile copy --destdir="$pkgdir"
  find . -maxdepth 2 -name 'LICENSE' | parallel --no-run-if-empty --no-notice "install -Dm444 {} $_licensedstdir/{}"
  popd >/dev/null
}

package() {
  _setupLocalEnvVars
  _installToPkgdir gitit
  _installToPkgdir pandoc
  _installToPkgdir pandoc-citeproc
}

# vim: set ft=sh syn=sh ts=2 sw=2 et:
