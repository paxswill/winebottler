#!/usr/bin/env bash

#
# build_wine.sh
# of the 'WineBottler' project
#
# Copyright 2009 Mike Kronenberg
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#

#TODO:
#USB http://forum.winehq.org/viewtopic.php?t=5663

export BUILD_BUNDLE=1
export WINE_VERSION=1.5.31



echo "\nbuilding Wine $WINE_VERSION"


#be flexible for build systems
if [ "$TERM" != "dumb" ]; then
    export PLC_FORMAT_FAILURE="\033[1;31m"
    export PLC_FORMAT_OK="\033[1;32m"
    export PLC_FORMAT_WARNING="\033[1;33m"
    export PLC_FORMAT_GRAY="\033[0;37m"
    export PLC_FORMAT_RESET="\033[0m"
    export PLC_COLS=70
    export PLC_COLS=$(($(tput cols) - 10))
else
    export PLC_COLS=70
fi



cleanup() {
    # HACK libiconv.la
    if [ $REMOVE_LIBICONVLA ]; then
        sudo rm "/usr/lib/libiconv.la"
    fi
}



logtext() {
    printf $(echo "%-"$PLC_COLS"."$PLC_COLS"s") "$1"
}
export -f logtext



logtextStatus() {
    case "$2" in
		1) printf "$PLC_FORMAT_WARNING";;
		2) printf "$PLC_FORMAT_FAILURE";;
		*) printf "$PLC_FORMAT_OK";;
    esac
    printf "%10s\n" "$1"
    printf "$PLC_FORMAT_RESET"
}
export -f logtextStatus



check_err() {
  if [ "${1}" -ne "0" ]; then
    logtextStatus "[FAILURE]" 2
    echo "\n***** Error: ${2}"
    cat ../build.log
    cleanup;
    exit ${1}
  fi
}



#http://ubuntuforums.org/showthread.php?t=1116012
unpack() {
    logtext "    unpack $1"
    if [ -f "$1" ] ; then
        case "$1" in
			*.tar.bz2)	tar xvjf "$1" > ../build.log 2>&1;;
			*.tar.gz)	tar xvzf "$1" > ../build.log 2>&1;;
			*.tar.xz)	unxz -c "$1" | tar xvpf - > ../build.log 2>&1;;
			*.bz2)		bunzip2 "$1" > ../build.log 2>&1;;
			*.rar)		unrar x "$1" > ../build.log 2>&1;;
			*.gz)		gunzip "$1" > ../build.log 2>&1;;
			*.tar)		tar xvf "$1" > ../build.log 2>&1;;
			*.tbz2)		tar xvjf "$1" > ../build.log 2>&1;;
			*.tgz)		tar xvzf "$1" > ../build.log 2>&1;;
			*.zip)		unzip "$1" > ../build.log 2>&1;;
			*.Z)		uncompress "$1" > ../build.log 2>&1;;
			*.7z)		7z x "$1" > ../build.log 2>&1;;
			*)		echo "don't know how to extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
    check_err $? "Can't unpack "$1
    logtextStatus "[OK]"
    rm $1
}



load() {
    #download
    if [ -z "$2" ]; then
        filename=$(basename "${1}")
    else
        filename=$2
    fi
    # chached
    if [ -f "../downloads/$filename" ]; then
        logtextStatus "[CACHED]" 1
        logtext "    copy from cache"
        cp "../downloads/$filename" "$filename"
        check_err $? "Can't copy "$filename
        logtextStatus "[OK]"
        unpack "$filename"
    # download
    else
        logtextStatus "[NOTFOUND]" 1
        logtext "    download $1"
        curl -s -L -o "../downloads/$filename" ${1}
        check_err $? "Can't download "$filename
        cp "../downloads/$filename" "$filename"
        check_err $? "Can't copy "$filename
        logtextStatus "[OK]"
        unpack "$filename"
    fi
}



configure_and_make() {
    logtext "    configure $2"
    cd "$1"
    ./configure $2 &> ../build.log
    check_err $? "Can't configure "$1
    logtextStatus "[OK]"
    logtext "    make --silent"
    make --silent &> ../build.log
    check_err $? "Can't make "$1
    logtextStatus "[OK]"
    touch "wine-built"
    cd - &>/dev/null
}



make_install() {
    logtext "    make install --silent"
    cd "$1"
    make install --silent &> ../build.log
    check_err $? "Can't make install "$1
    logtextStatus "[OK]"
    cd - &>/dev/null
}



prepare() {
    echo "\n$1-$2"
    logtext "    check availabiliy"
    if [ ! -f "$1-$2/wine-built" ]; then
        rm -rf "$1*"
        load "$3"
        configure_and_make "$1-$2" "$4"
    else
        logtextStatus "[PREBUILT]" 1
    fi
    make_install "$1-$2"
}



tarcp() {
  (cd "$1"; tar cfv - . ) | ( mkdir -p "$2"; cd "$2" ; tar xfpv - )
}



# setup environment
export BUILDDIRECTORY=$(PWD)
echo "" > build.log
rm -rf "$BUILDDIRECTORY/usr" &> /dev/null
mkdir -p "$BUILDDIRECTORY/usr/include"
mkdir -p "$BUILDDIRECTORY/usr/lib"
mkdir -p "$BUILDDIRECTORY/usr/bin"
mkdir -p "$BUILDDIRECTORY/usr/etc"
mkdir -p "$BUILDDIRECTORY/usr/man/man1"
mkdir -p "$BUILDDIRECTORY/downloads"
mkdir -p "$BUILDDIRECTORY/src"
rm -rf "$BUILDDIRECTORY/Wine"
mkdir -p "$BUILDDIRECTORY/Wine"
cd src



# exports
export CPPFLAGS="\
    -I$BUILDDIRECTORY/usr/include\
    -I$BUILDDIRECTORY/usr/include/fontforge\
    -I$BUILDDIRECTORY/usr/include/freetype2\
    -I$BUILDDIRECTORY/usr/include/gphoto2\
    -I$BUILDDIRECTORY/usr/include/libexslt\
    -I$BUILDDIRECTORY/usr/include/libxml2\
    -I$BUILDDIRECTORY/usr/include/libxslt\
    -I$BUILDDIRECTORY/usr/include/sane\
    -I/usr/X11/include"
export CFLAGS="-O2 -arch i386 -m32 -I$BUILDDIRECTORY/usr/include"
export CXXFLAGS="$CFLAGS "
export LDFLAGS=" -arch i386 -L$BUILDDIRECTORY/usr/lib"
export PATH="$BUILDDIRECTORY/usr/bin:$PATH"
export DYLD_LIBRARY_PATH="$BUILDDIRECTORY/usr/lib:$DYLD_LIBRARY_PATH"
export DYLD_FALLBACK_LIBRARY_PATH="$BUILDDIRECTORY/usr/lib"
export PKG_CONFIG_PATH="$BUILDDIRECTORY/usr/lib/pkgconfig"



# dependencies

# libgphoto2 needs "/usr/lib/libiconv.la", so we fake one, as apple did supply the .dylib, but not included the .la
if [ ! -f "/usr/lib/libiconv.la" ]; then
    export REMOVE_LIBICONVLA=1
    cat > "/tmp/libiconv.la" <<_EOF_
        dlname='libiconv.2.dylib'
        library_names='libiconv.2.dylib libiconv.dylib'
        old_library=''
        inherited_linker_flags=' '
        #dependency_libs=' -L/Users/mike/Documents/wine/usr/lib'
        weak_library_names=''
        current=7
        age=5
        revision=1
        installed=no
        shouldnotlink=no
        dlopen=''
        dlpreopen=''
        libdir='/usr/lib'
_EOF_
    sudo cp "/tmp/libiconv.la" "/usr/lib/libiconv.la"
fi



# gsm with it's missing configure ...
GSM_VERSION=1.0.13
echo "\ngsm-$GSM_VERSION"
logtext "    check availabiliy"
if [ ! -f "gsm-$GSM_VERSION/wine-built" ]; then
    rm -rf "gsm*"
    load "http://www.quut.com/gsm/gsm-$GSM_VERSION.tar.gz"
    mv "gsm-1.0-pl13" "gsm-$GSM_VERSION"
    cd "gsm-$GSM_VERSION"
    logtext "    configure 'sed -i .bak s|^INSTALL_ROOT.*=|INSTALL_ROOT='${BUILDDIRECTORY}'/usr|' Makefile"
    sed -i .bak -e 's|^INSTALL_ROOT.*=|INSTALL_ROOT='${BUILDDIRECTORY}'/usr|' -e 's|DNeedFunctionPrototypes=1|DNeedFunctionPrototypes=1 -arch i386|' Makefile;
    logtextStatus "[OK]"
    logtext "    make"
    make &> ../build.log
    logtextStatus "[OK]"
    cd - &> /dev/null
    touch "gsm-$GSM_VERSION/wine-built"
else
    logtextStatus "[PREBUILT]" 1
fi
logtext "    make install (libtool -arch_only i386 -v -dynamic -compatibility_version $GSM_VERSION -current_version $GSM_VERSION -o $BUILDDIRECTORY/usr/lib/gsm.$GSM_VERSION.dylib -lc *.o &>/dev/null)"
cp gsm-$GSM_VERSION/inc/gsm.h "../usr/include/"
cd "gsm-$GSM_VERSION/src"
libtool -arch_only i386 -v -dynamic -install_name @loader_path/../lib/libgsm.$GSM_VERSION.dylib -compatibility_version $GSM_VERSION -current_version $GSM_VERSION -o "$BUILDDIRECTORY/usr/lib/libgsm.$GSM_VERSION.dylib" -lc *.o &> ../../build.log
check_err $? "Can't make install "$1
cd "$BUILDDIRECTORY/usr/lib/"
ln -s "libgsm.$GSM_VERSION.dylib" "libgsm.dylib"
check_err $? "Can't make ln "$1
cd "$BUILDDIRECTORY/src" &> /dev/null
logtextStatus "[OK]"





# ntlm_auth needed by wine on OS X 10.7+ (where Apple has removed SAMBA)
export SAMBA_VERSION=3.6.14
echo "\nsamba-$SAMBA_VERSION"
logtext "    check availabiliy"
if [ ! -f "samba-$SAMBA_VERSION/source3/wine-built" ]; then
	rm -rf "samba*"
	load "http://ftp.samba.org/pub/samba/samba-$SAMBA_VERSION.tar.gz"
	configure_and_make "samba-$SAMBA_VERSION/source3" '--silent --enable-shared --disable-static --disable-largefile --disable-swat --disable-smbtorture4 --disable-cups --disable-pie --disable-relro --disable-external-libtalloc --disable-external-libtdb --disable-fam --disable-dnssd --disable-avahi --without-dmapi --without-ldap --without-dnsupdate --without-pam --without-pam_smbpass --without-utmp --without-cluster-support --without-acl-support --without-sendfile-support --with-included-popt --with-included-iniparser --with-winbind --prefix='$BUILDDIRECTORY'/usr'
else
	logtextStatus "[PREBUILT]" 1
fi
logtext "    make install --silent"
cd "$BUILDDIRECTORY/usr/lib/"
cp "$BUILDDIRECTORY/src/samba-$SAMBA_VERSION/source3/bin/libtalloc.dylib.2.0.5" "$BUILDDIRECTORY/usr/lib/"
ln -s "libtalloc.dylib.2.0.5" "libtalloc.dylib.2"
ln -s "libtalloc.dylib.2" "libtalloc.dylib"
cp "$BUILDDIRECTORY/src/samba-$SAMBA_VERSION/source3/bin/libtdb.dylib.1.2.9" "$BUILDDIRECTORY/usr/lib/"
ln -s "libtdb.dylib.1.2.9" "libtdb.dylib.1"
ln -s "libtdb.dylib.1" "libtdb.dylib"
cp "$BUILDDIRECTORY/src/samba-$SAMBA_VERSION/source3/bin/libwbclient.dylib.0" "$BUILDDIRECTORY/usr/lib/"
ln -s "libwbclient.dylib.0" "libwbclient.dylib"
cp "$BUILDDIRECTORY/src/samba-$SAMBA_VERSION/source3/bin/winbindd" "$BUILDDIRECTORY/usr/bin/"
cp "$BUILDDIRECTORY/src/samba-$SAMBA_VERSION/source3/bin/ntlm_auth" "$BUILDDIRECTORY/usr/bin/"
cd "$BUILDDIRECTORY/src" &> /dev/null
logtextStatus "[OK]"

# libtld needed by libmpg123 (this file is not shipped by stock OS, only by XCode, so we need to package it!)
export LIBTLD_VERSION=2.4.2 && prepare libtool $LIBTLD_VERSION "http://ftp.gnu.org/gnu/libtool/libtool-$LIBTLD_VERSION.tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'

# libmpg123 (can't build with --with-cpu=x86_64)
#export LIBMPG123_VERSION=1.14.3 && prepare mpg123 $LIBMPG123_VERSION "http://www.mpg123.de/download/mpg123-$LIBMPG123_VERSION.tar.bz2" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --with-cpu=generic_fpu'
export LIBMPG123_VERSION=1.15.3 && prepare mpg123 $LIBMPG123_VERSION "http://www.mpg123.de/download/mpg123-$LIBMPG123_VERSION.tar.bz2" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --with-cpu=generic_fpu'

# lcms2
export LCMS_VERSION=1.19 && prepare lcms $LCMS_VERSION "http://kent.dl.sourceforge.net/project/lcms/lcms/"$LCMS_VERSION"/lcms-"$LCMS_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'
#export LCMS_VERSION=2.3 && prepare lcms2 $LCMS_VERSION "http://ignum.dl.sourceforge.net/project/lcms/lcms/"$LCMS_VERSION"/lcms2-"$LCMS_VERSION".tar.gz" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr'

# libjpeg
export LIBJPEG_VERSION=8d && prepare jpeg $LIBJPEG_VERSION "http://www.ijg.org/files/jpegsrc.v"$LIBJPEG_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'
#tiff is not building with this! export LIBJPEG_VERSION=9 && prepare jpeg $LIBJPEG_VERSION "http://www.ijg.org/files/jpegsrc.v"$LIBJPEG_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'

# tiff
#export LIBTIFF_VERSION=4.0.2 && prepare tiff $LIBTIFF_VERSION "ftp://ftp.remotesensing.org/pub/libtiff/tiff-"$LIBTIFF_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'
export LIBTIFF_VERSION=4.0.3 && prepare tiff $LIBTIFF_VERSION "ftp://ftp.remotesensing.org/pub/libtiff/tiff-"$LIBTIFF_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'


# libpng
if test $(echo $OSTYPE | grep darwin10); then
#    export LIBPNG_VERSION=1.5.12 && prepare libpng $LIBPNG_VERSION "ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-"$LIBPNG_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'
    export LIBPNG_VERSION=1.6.1 && prepare libpng $LIBPNG_VERSION "http://ignum.dl.sourceforge.net/project/libpng/libpng16/older-releases/"$LIBPNG_VERSION"/libpng-"$LIBPNG_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'
fi

# pkg-config (used by libgphoto2), 0.23+ needs glib, so we stay with 0.23
export PKG_CONFIG_VERSION=0.23 && prepare pkg-config $PKG_CONFIG_VERSION "http://pkgconfig.freedesktop.org/releases/pkg-config-"$PKG_CONFIG_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'

# libusb (may be used by libgphoto2, libsane)
export LIBUSB_VERSION=1.0.9 && prepare libusb $LIBUSB_VERSION "http://netcologne.dl.sourceforge.net/project/libusb/libusb-1.0/libusb-$LIBUSB_VERSION/libusb-$LIBUSB_VERSION.tar.bz2" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'

# libusb-compat (used by older libusb devices)
export LIBUSBCOMPAT_VERSION=0.1.4 && prepare libusb-compat $LIBUSBCOMPAT_VERSION "http://garr.dl.sourceforge.net/project/libusb/libusb-compat-0.1/libusb-compat-$LIBUSBCOMPAT_VERSION/libusb-compat-$LIBUSBCOMPAT_VERSION.tar.bz2" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'

# libgphoto2 (needs "/usr/lib/libiconv.la", so we fake one, as apple did not include one)
export LIBGPHOTO2_VERSION=2.4.14 && prepare libgphoto2 $LIBGPHOTO2_VERSION "http://dfn.dl.sourceforge.net/sourceforge/gphoto/libgphoto2-"$LIBGPHOTO2_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --with-iconv=/usr'
#export LIBGPHOTO2_VERSION=2.5.1.1 && prepare libgphoto2 $LIBGPHOTO2_VERSION "http://heanet.dl.sourceforge.net/project/gphoto/libgphoto/"$LIBGPHOTO2_VERSION"/libgphoto2-"$LIBGPHOTO2_VERSION".tar.bz2" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --with-iconv=/usr'

# libssane-backendsane
#export LIBSANE_VERSION=1.0.22 && prepare sane-backends $LIBSANE_VERSION "ftp://ftp2.sane-project.org/pub/sane/sane-backends-"$LIBSANE_VERSION"/sane-backends-"$LIBSANE_VERSION".tar.gz" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr --with-gphoto2'
#export LIBSANE_VERSION=git20120630 && prepare sane-backends $LIBSANE_VERSION "ftp://ftp2.sane-project.org/pub/sane/sane-backends-"$LIBSANE_VERSION"/sane-backends-"$LIBSANE_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --with-gphoto2'
export LIBSANE_VERSION=1.0.23 && prepare sane-backends $LIBSANE_VERSION "ftp://ftp2.sane-project.org/pub/sane/sane-backends-$LIBSANE_VERSION.tar.gz" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr --with-gphoto2'

# freetype (needed by wine and fontconfig)
#export FREETYPE_VERSION=2.4.10 && prepare freetype $FREETYPE_VERSION "http://mirrors.zerg.biz/nongnu/freetype/freetype-"$FREETYPE_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'
export FREETYPE_VERSION=2.4.11 && prepare freetype $FREETYPE_VERSION "http://mirrors.zerg.biz/nongnu/freetype/freetype-"$FREETYPE_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'

# fontconfig
#export FONTCONFIG_VERSION=2.9.92 && prepare fontconfig $FONTCONFIG_VERSION "http://www.fontconfig.org/release/fontconfig-"$FONTCONFIG_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --with-add-fonts=/usr/X11/lib/X11/fonts --with-add-fonts=/Library/Fonts --with-add-fonts=/Network/Library/Fonts --with-add-fonts=$BUILDDIRECTORY/share/fonts'
export FONTCONFIG_VERSION=2.10.0 && prepare fontconfig $FONTCONFIG_VERSION "http://www.fontconfig.org/release/fontconfig-"$FONTCONFIG_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --with-add-fonts=/usr/X11/lib/X11/fonts --with-add-fonts=/Library/Fonts --with-add-fonts=/Network/Library/Fonts --with-add-fonts=$BUILDDIRECTORY/share/fonts'

# fontforge
#sudo mkdir -p "/Developer/Headers/FlatCarbon"
#sudo cp "/Applications/Xcode.app/Contents/Developer/Headers/FlatCarbon/Files.h" "/Developer/Headers/FlatCarbon/Files.h"
#export FONTFORGE_VERSION=20110222 && prepare fontforge $FONTFORGE_VERSION "http://kent.dl.sourceforge.net/sourceforge/fontforge/fontforge_full-$FONTFORGE_VERSION.tar.bz2" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --disable-macapp --without-x --with-freetype-src=../freetype-'$FREETYPE_VERSION
#sudo rm -rf "/Developer/Headers/FlatCarbon/Files.h"

# libxml2
#export LIBXML2_VERSION=2.8.0 && prepare libxml2 $LIBXML2_VERSION "ftp://xmlsoft.org/libxml2/libxml2-"$LIBXML2_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'
export LIBXML2_VERSION=2.9.1 && prepare libxml2 $LIBXML2_VERSION "ftp://xmlsoft.org/libxml2/libxml2-"$LIBXML2_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'

# libxslt
#export LIBXSLT_VERSION=1.1.26 && prepare libxslt $LIBXSLT_VERSION "ftp://xmlsoft.org/libxml2/libxslt-"$LIBXSLT_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --with-libxml-src='$BUILDDIRECTORY'/src/libxml2-'$LIBXML2_VERSION
export LIBXSLT_VERSION=1.1.28 && prepare libxslt $LIBXSLT_VERSION "ftp://xmlsoft.org/libxml2/libxslt-"$LIBXSLT_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr --with-libxml-src='$BUILDDIRECTORY'/src/libxml2-'$LIBXML2_VERSION

#gettext
if test $(echo $OSTYPE | grep darwin10); then
#    export GETTEXT_VERSION=0.18.1.1 && prepare gettext $GETTEXT_VERSION "http://ftp.gnu.org/pub/gnu/gettext/gettext-"$GETTEXT_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'
    export GETTEXT_VERSION=0.18.2 && prepare gettext $GETTEXT_VERSION "http://ftp.gnu.org/pub/gnu/gettext/gettext-"$GETTEXT_VERSION".tar.gz" '--silent --enable-shared --disable-static --prefix='$BUILDDIRECTORY'/usr'
fi


if test $(echo $OSTYPE | grep darwin10); then
    WB_OUT="out"
fi

# wine
echo "\nwine"-$WINE_VERSION
logtext "    check availabiliy"
if [ ! -f "wine-$WINE_VERSION/wine-built" ]; then
    rm -rf wine-*
    load "http://ibiblio.org/pub/linux/system/emulators/wine/wine-$WINE_VERSION.tar.bz2"
    cd "wine-$WINE_VERSION"
    
    
    # no more patches :)
    #patch -p1 -u < "../../diff/24b66842c4d72676a3552f5888f80ce4bc76d51c.diff"
    #patch -p1 < "../../diff/ce4b6451aabbe83809c7483c748cfa009cc090d6.patch"
    
    #gnutls not needed: https://trac.macports.org/ticket/29909
    
    WINE_CONFIGURE="\
        --verbose\
        --prefix=$BUILDDIRECTORY/usr\
        --enable-win16\
        --disable-win64\
        --without-alsa\
        --without-capi\
        --with-cms\
        --with-coreaudio\
        --with-cups\
        --with-curses\
        --without-dbus\
        --with-fontconfig\
        --with-freetype\
        --with-gettext\
        --with-gettextpo\
        --with-gphoto\
        --with-glu\
        --without-gnutls\
        --with-gsm\
        --without-gstreamer\
        --without-hal\
        --with-jpeg\
        --with-ldap\
        --with-mpg123\
        --with-openal\
        --without-opencl\
        --with-opengl\
        --without-oss\
        --with-png\
        --with-pthread\
        --with-sane\
        --with-tiff\
        --without-v4l\
        --with"$WB_OUT"-xinput2\
        --with-xml\
        --with-xslt\
        --with-zlib"
    echo "    building width"
    printf "        $(sed 's| |\\n        |g' <<< $(printf "$WINE_CONFIGURE"))\n"
    logtext "    configure"
    export CC=gcc-4.2
    #export CC=/usr/llvm-gcc-4.2/bin/llvm-gcc-4.2
    ./configure $WINE_CONFIGURE &>../build.log
    check_err $? "Can't configure wine"
    cat ../build.log | grep -e "/configure: [^F][^i][^n][^i][^s][^h][^e][^d]/g" -e "WARNING:"
    logtextStatus "[OK]"
    logtext "    make -s"
    CFLAGS="-O2 -m32 -I$BUILDDIRECTORY/usr/include" make -s &>../build.log
    check_err $? "Can't make wine"
    touch "wine-built"
    logtextStatus "[OK]"
    cd - &>/dev/null
else
    logtextStatus "[PREBUILT]"
fi
make_install "wine-$WINE_VERSION"



# change fontconfig path
    logtext "    change fontconfig path"
mv "$BUILDDIRECTORY/usr/etc/fonts/fonts.conf" "$BUILDDIRECTORY/usr/etc/fonts/fonts.conf.tmp"
cat "$BUILDDIRECTORY/usr/etc/fonts/fonts.conf.tmp" | sed -e 's/<cachedir>\/Users\/mike\/Documents\/wine\/usr\/var\/cache\/fontconfig<\/cachedir>//'\
    -e 's/<include ignore_missing="yes">\/Users\/mike\/Documents\/wine\/usr\/etc\/fonts\/conf.d<\/include>//'\
     > "$BUILDDIRECTORY/usr/etc/fonts/fonts.conf"
check_err $? "Can't make wine"
rm "$BUILDDIRECTORY/usr/etc/fonts/fonts.conf.tmp"
logtextStatus "[OK]"



# create startwine
    logtext "    create startwine"
cat > "$BUILDDIRECTORY/usr/bin/startwine" <<_EOF_
#!/usr/bin/env bash
# get current path
if test \$(echo \$0 | grep "Wine.app/Contents/MacOS/startwine"); then
    WINE_DIRNAME="\$(dirname "\$0")/../Resources"
else
    WINE_DIRNAME="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && cd .. && pwd )"
fi
# exports to ensure wine finds all libs in the bundle
export PATH="\$WINE_DIRNAME/bin":\$PATH
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:"\$WINE_DIRNAME/lib":"/usr/X11/lib"
export DYLD_FALLBACK_LIBRARY_PATH="/usr/lib":"\$WINE_DIRNAME/lib":"/usr/X11/lib"
export FONTCONFIG_FILE="\$WINE_DIRNAME/etc/fonts/fonts.conf"
# start wine
exec "\$WINE_DIRNAME/bin/wine" "\$@"
_EOF_
check_err $? "Can't create startwine"
chmod a+x "$BUILDDIRECTORY/usr/bin/startwine"
check_err $? "Can't chmod startwine"
logtextStatus "[OK]"



# Mac OS App bundle
if [ $BUILD_APP ]; then
    logtext "    create Wine.app"
    rm -rf "$BUILDDIRECTORY/Wine/Wine.app"
    mkdir -p "$BUILDDIRECTORY/Wine/Wine.app/Contents/MacOS"
    echo "APPL????" > "$BUILDDIRECTORY/Wine/Wine.app/Contents/PkgInfo"
    cat > "$BUILDDIRECTORY/Wine/Wine.app/Contents/Info.plist" <<_EOF_
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>startwine</string>
	<key>CFBundleIconFile</key>
	<string>Icon.icns</string>
	<key>CFBundleIdentifier</key>
	<string>org.kronenberg.wine</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleVersion</key>
	<string>$WINE_VERSION</string>
</dict>
</plist>
_EOF_
    cp  "$BUILDDIRECTORY/usr/bin/startwine" "$BUILDDIRECTORY/Wine/Wine.app/Contents/MacOS/startwine"
    check_err $? "Can't copy startwine"
    chmod a+x "$BUILDDIRECTORY/Wine/Wine.app/Contents/MacOS/startwine"
    check_err $? "Can't chmod startwine"
    
    mkdir -p "$BUILDDIRECTORY/Wine/Wine.app/Contents/Resources"
    check_err $? "Can't create Wine.app/Resources"
    
    tarcp "$BUILDDIRECTORY/usr/" "$BUILDDIRECTORY/Wine/Wine.app/Contents/Resources/" &> /dev/null
    check_err $? "Can't tarcp Wine"
    
    logtextStatus "[OK]"
fi



#Wine_X.X.X.bundle
if [ $BUILD_BUNDLE ]; then
    logtext "    create Wine_$WINE_VERSION.bundle"
    mkdir -p "$BUILDDIRECTORY/Wine/Wine_$WINE_VERSION.bundle/Contents/Resources"
    check_err $? "Can't create Wine_$WINE_VERSION.bundle/Resources"
    tarcp "$BUILDDIRECTORY/usr/" "$BUILDDIRECTORY/Wine/Wine_$WINE_VERSION.bundle/Contents/Resources/" &> /dev/null
    check_err $? "Can't tarcp Wine"
    logtextStatus "[OK]"
fi



#gecko
export GECKO_VERSION=1.9
echo "\ngecko"
logtext "    check availabiliy"
if [ ! -f "$BUILDDIRECTORY/downloads/wine_gecko-$GECKO_VERSION-x86.msi" ]; then
    logtextStatus "[NOTFOUND]" 1
    logtext "    download http://downloads.sourceforge.net/wine/wine_gecko-$GECKO_VERSION-x86.msi"
    curl -L -s -o "$BUILDDIRECTORY/downloads/wine_gecko-$GECKO_VERSION-x86.msi" "http://downloads.sourceforge.net/wine/wine_gecko-$GECKO_VERSION-x86.msi"
    check_err $? "Can't download gecko"
else
    logtextStatus "[CACHED]" 1
    logtext "    copy from cache"
fi
mkdir -p "$BUILDDIRECTORY/Wine/Wine_$WINE_VERSION.bundle/Contents/Resources/share/wine/gecko"
check_err $? "Can't create folder for gecko"
cp "$BUILDDIRECTORY/downloads/wine_gecko-$GECKO_VERSION-x86.msi" "$BUILDDIRECTORY/Wine/Wine_$WINE_VERSION.bundle/Contents/Resources/share/wine/gecko/wine_gecko-$GECKO_VERSION-x86.msi"
check_err $? "Can't copy gecko"
logtextStatus "[OK]"



#mono
export MONO_VERSION=0.0.8
echo "\nmono"
logtext "    check availabiliy"
if [ ! -f "$BUILDDIRECTORY/downloads/wine-mono-$MONO_VERSION.msi" ]; then
    logtextStatus "[NOTFOUND]" 1
    logtext "    download http://garr.dl.sourceforge.net/project/wine/Wine%20Mono/$MONO_VERSION/wine-mono-$MONO_VERSION.msi"
    curl -L -s -o "$BUILDDIRECTORY/downloads/wine-mono-$MONO_VERSION.msi" "http://garr.dl.sourceforge.net/project/wine/Wine%20Mono/$MONO_VERSION/wine-mono-$MONO_VERSION.msi"
    check_err $? "Can't download mono"
else
    logtextStatus "[CACHED]" 1
    logtext "    copy from cache"
fi
mkdir -p "$BUILDDIRECTORY/Wine/Wine_$WINE_VERSION.bundle/Contents/Resources/share/wine/mono"
check_err $? "Can't create folder for mono"
cp "$BUILDDIRECTORY/downloads/wine-mono-$MONO_VERSION.msi" "$BUILDDIRECTORY/Wine/Wine_$WINE_VERSION.bundle/Contents/Resources/share/wine/mono/wine-mono-$MONO_VERSION.msi"
check_err $? "Can't copy mono"
logtextStatus "[OK]"


cleanup

echo "\nFinished!"
