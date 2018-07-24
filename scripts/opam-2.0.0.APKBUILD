# Contributor: Michael Zuo <muh.muhten@gmail.com>
# Maintainer: Anil Madhavapeddy <anil@recoil.org>
# FIXME: lib-ext downloads dependencies; package them and use system-provided!
pkgname=opam
pkgver=2.0.0
pkgtag=2.0.0-rc4
pkgrel=4
pkgdesc="OCaml Package Manager"
url="https://opam.ocaml.org"
arch="all !x86 !armhf !s390x"  # ocaml not avail on excluded platforms
license="LGPL-3.0"
depends="curl tar unzip rsync patch"
makedepends="ocaml"
subpackages="$pkgname-doc"
source="https://github.com/ocaml/$pkgname/releases/download/$pkgtag/$pkgname-full-$pkgver.tar.gz"
builddir="$srcdir/$pkgname-full-$pkgver"

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

sha512sums="52578df202bbf97ff2c0b87d026080315ce4b7cd6ee8e25f25303cb3ced504ed36279df357bd3fc2e6339832247d7358c40b3075fe64ccc507704b1403c0c3a6  opam-full-2.0.0.tar.gz"
