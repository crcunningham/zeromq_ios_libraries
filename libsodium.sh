#!/bin/bash

LIBNAME="libsodium.a"
#ARCHS=${ARCHS:-"armv7 armv7s arm64 x86_64"}
ARCHS=${ARCHS:-"x86_64"}
VALID_ARCHS="x86_64"
DEVELOPER=$(xcode-select -print-path)
LIPO=$(xcrun -sdk iphoneos -find lipo)
#LIPO=lipo
# Script's directory
SCRIPTDIR=$( (cd -P $(dirname $0) && pwd) )
# libsodium root directory
LIBDIR=$( (cd "${SCRIPTDIR}/libsodium" && pwd) )
# Destination directory for build and install
DSTDIR=${SCRIPTDIR}
BUILDDIR="${DSTDIR}/libsodium_build"
DISTDIR="${DSTDIR}/libsodium_dist"
DISTLIBDIR="${DISTDIR}/lib"
# http://libwebp.webm.googlecode.com/git/iosbuild.sh
# Extract the latest SDK version from the final field of the form: iphoneosX.Y
PhoneSDK=$(xcodebuild -showsdks \
    | grep iphoneos | sort | tail -n 1 | awk '{print substr($NF, 9)}'
)
SimSDK=$(xcodebuild -showsdks \
    | grep iphonesimulator | sort | tail -n 1 | awk '{print substr($NF, 16)}'
)

OTHER_CFLAGS="-Os -Qunused-arguments"

# Cleanup
if [ -d $BUILDDIR ]
then
    rm -rf $BUILDDIR
fi
if [ -d $DISTDIR ]
then
    rm -rf $DISTDIR
fi
mkdir -p $BUILDDIR $DISTDIR

# Generate autoconf files
cd ${LIBDIR}; ./autogen.sh

# Iterate over archs and compile static libs
for ARCH in $ARCHS
do
    BUILDARCHDIR="$BUILDDIR/$ARCH"
    mkdir -p ${BUILDARCHDIR}

    case ${ARCH} in
        armv7)
	    PLATFORM="iPhoneOS"
	    HOST="${ARCH}-apple-darwin"
	    export BASEDIR="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	    export ISDKROOT="${BASEDIR}/SDKs/${PLATFORM}${PhoneSDK}.sdk"
	    export CFLAGS="-arch ${ARCH} -isysroot ${ISDKROOT} ${OTHER_CFLAGS}"
	    export LDFLAGS="-mthumb -arch ${ARCH} -isysroot ${ISDKROOT}"
            ;;
        armv7s)
	    PLATFORM="iPhoneOS"
	    HOST="${ARCH}-apple-darwin"
	    export BASEDIR="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	    export ISDKROOT="${BASEDIR}/SDKs/${PLATFORM}${PhoneSDK}.sdk"
	    export CFLAGS="-arch ${ARCH} -isysroot ${ISDKROOT} ${OTHER_CFLAGS}"
	    export LDFLAGS="-mthumb -arch ${ARCH} -isysroot ${ISDKROOT}"
            ;;
        arm64)
	    PLATFORM="iPhoneOS"
	    HOST="arm-apple-darwin"
	    export BASEDIR="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	    export ISDKROOT="${BASEDIR}/SDKs/${PLATFORM}${PhoneSDK}.sdk"
	    export CFLAGS="-arch ${ARCH} -isysroot ${ISDKROOT} ${OTHER_CFLAGS}"
	    export LDFLAGS="-mthumb -arch ${ARCH} -isysroot ${ISDKROOT}"
            ;;
        i386)
	    PLATFORM="iPhoneSimulator"
	    HOST="${ARCH}-apple-darwin"
	    export BASEDIR="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	    export ISDKROOT="${BASEDIR}/SDKs/${PLATFORM}${SimSDK}.sdk"
	    export CFLAGS="-arch ${ARCH} -isysroot ${ISDKROOT} -miphoneos-version-min=${SimSDK} ${OTHER_CFLAGS}"
	    export LDFLAGS="-m32 -arch ${ARCH}"
            ;;
        x86_64)
	    PLATFORM="iPhoneSimulator"
	    HOST="${ARCH}-apple-darwin"
	    export BASEDIR="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	    export ISDKROOT="${BASEDIR}/SDKs/${PLATFORM}${SimSDK}.sdk"
	    export CFLAGS="-arch ${ARCH} -isysroot ${ISDKROOT} -miphoneos-version-min=${SimSDK} ${OTHER_CFLAGS}"

        export CC=$(xcrun --sdk iphonesimulator${SimSDK} --find gcc)
        export CPP=$(xcrun --sdk iphonesimulator${SimSDK} --find gcc)" -E"
        export CXX=$(xcrun --sdk iphonesimulator${SimSDK} --find g++)
        export LD=$(xcrun --sdk iphonesimulator${SimSDK} --find ld)


	    export LDFLAGS="-arch ${ARCH} -isysroot ${ISDKROOT} -mios-version-min=${IOS_VERSION_MIN} ${OTHER_LDFLAGS}"
            ;;
        *)
            echo "Unsupported architecture ${ARCH}"
            exit 1
            ;;
    esac

    export PATH="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin:${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/sbin:$PATH"

    echo "Configuring for ${ARCH}..."
    ${LIBDIR}/configure \
	--prefix=${BUILDARCHDIR} \
	--disable-shared \
	--enable-static \
    --target="x86_64-apple-darwin_sim"\
    --host=${HOST}

    echo "Building ${LIBNAME} for ${ARCH}..."
    cd ${LIBDIR}
    make clean
    make -j8 V=0
    make install

    LIBLIST+="${BUILDARCHDIR}/lib/${LIBNAME} "
done

# Copy headers and generate a single fat library file
mkdir -p ${DISTLIBDIR}
${LIPO} -create ${LIBLIST} -output ${DISTLIBDIR}/${LIBNAME}
for ARCH in $ARCHS
do
    cp -R $BUILDDIR/$ARCH/include ${DISTDIR}
    break
done

# Cleanup
rm -rf ${BUILDDIR}

