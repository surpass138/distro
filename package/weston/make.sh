#!/bin/bash

set -e
DEPENDENCIES="libdrm libpng-dev libjpeg-dev libegl1-mesa-dev libgles2-mesa-dev libgbm-dev libudev-dev libinput-dev libpixman-1-dev libxkbcommon-dev wayland-protocols libcairo2-dev libdbus-1-dev libxml2-dev libpam0g-dev"
$SCRIPTS_DIR/build_pkgs.sh $ARCH $SUITE "$DEPENDENCIES"
PKG=weston
VERSION=3.0.0
if [ ! -e $DOWNLOAD_DIR/$PKG-$VERSION.tar.gz ];then
        wget -O $DOWNLOAD_DIR/$PKG-$VERSION.tar.gz https://github.com/wayland-project/weston/archive/$VERSION.tar.gz
fi

if [ ! -d $BUILD_DIR/$PKG-$VERSION ];then
        tar -xzf $DOWNLOAD_DIR/$PKG-$VERSION.tar.gz -C $BUILD_DIR
fi
sed -i 's/^Version.*/Version: 17/g' $TARGET_DIR/usr/lib/$TOOLCHAIN/pkgconfig/gbm.pc
cd $BUILD_DIR/$PKG-$VERSION
if [ -d $DISTRO_DIR/package/$PKG/$VERSION ]; then
	for p in $(ls $DISTRO_DIR/package/$PKG/$VERSION/*.patch); do
		echo "apply patch: "$p
		patch -p1 < $p;
	done
fi

./autogen.sh --target=aarch64-linux-gnu --host=aarch64-linux-gnu --prefix=/usr --libdir=/usr/lib/$TOOLCHAIN --disable-dependency-tracking --disable-static --enable-shared  --disable-headless-compositor --disable-colord --disable-devdocs --disable-setuid-install --enable-dbus --enable-weston-launch --enable-egl --disable-rdp-compositor --disable-fbdev-compositor --enable-drm-compositor WESTON_NATIVE_BACKEND=drm-backend.so --disable-x11-compositor --disable-xwayland --disable-vaapi-recorder --disable-lcms --disable-systemd-login --disable-systemd-notify --enable-junit-xml --disable-demo-clients-install
make WAYLAND_PROTOCOLS_DATADIR=$TARGET_DIR/usr/share/wayland-protocols -j$RK_JOBS
make install
cd -

