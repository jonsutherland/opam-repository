# Contributor: Sören Tempel <soeren+alpine@soeren-tempel.net>
# Maintainer:
pkgname=hidapi
pkgver=0.9.0
_relver="$(echo "$pkgver" | sed s/_/-/)"
pkgrel=0
pkgdesc="Simple library for communicating with USB and Bluetooth HID devices"
url="http://libusb.info"
arch="all"
license="custom"
depends=""
depends_dev=""
options="!check"
makedepends="libusb-dev libtool eudev-dev linux-headers autoconf automake"
install=""
subpackages="$pkgname-dev $pkgname-doc"
source="$pkgname-$pkgver.tar.gz::https://github.com/libusb/$pkgname/archive/$pkgname-${_relver}.tar.gz"
builddir="$srcdir/$pkgname-$pkgname-$_relver"

prepare() {
	default_prepare
	cd "$builddir"
	./bootstrap
}

build() {
	cd "$builddir"
	./configure \
		--build=$CBUILD \
		--host=$CHOST \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--localstatedir=/var
	make
}

package() {
	cd "$builddir"
	make DESTDIR="$pkgdir" install

	mkdir -p "$pkgdir"/usr/share/licenses/$pkgname
	mv "$pkgdir"/usr/share/doc/$pkgname/LICENSE* \
		"$pkgdir"/usr/share/licenses/$pkgname
}

sha512sums="d9f28d394b78daece7d2dfb946e62349a56b388b3a06241585c6fad5a4e24dc914723de6c0f12a9e51cd23fb245f6b5ac9b3721319646d5ba5912bbe0a3f9a52  hidapi-0.9.0.tar.gz"
