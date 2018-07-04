# Contributor: Michael Zuo <muh.muhten@gmail.com>
# Maintainer: Anil Madhavapeddy <anil@recoil.org>
# FIXME: lib-ext downloads dependencies; package them and use system-provided!
pkgname=opam
pkgver=2.0.0_rc3
pkgtag=2.0.0-rc3
pkgrel=4
pkgdesc="OCaml Package Manager"
url="https://opam.ocaml.org"
arch="all !x86 !armhf !s390x"  # ocaml not avail on excluded platforms
license="LGPL-3.0"
depends="curl tar unzip rsync patch"
makedepends="ocaml"
subpackages="$pkgname-doc"
source="https://github.com/ocaml/$pkgname/releases/download/$pkgtag/$pkgname-full-$pkgtag.tar.gz"
builddir="$srcdir/$pkgname-full-$pkgtag"

build() {
	cd "$builddir"

	./configure \
		--build=$CBUILD \
		--host=$CHOST \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--localstatedir=/var

	# -unsafe-string needed to make it build with ocaml >=4.06.
	OCAMLFLAGS="-unsafe-string" \
		make -j1 lib-ext all
}

package() {
	cd "$builddir"
	make DESTDIR="$pkgdir" install
}

sha512sums="b4926a52b318d4e4b56ff17caaed3f6d7fb2eaa31510437357234df43ba318f40fe784ec5a840a93d1865c55ba70327f16277d06fe374539b43c69d07361384e  opam-full-2.0.0-rc3.tar.gz"
