#!/bin/bash

set -o xtrace

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# from https://download.libsodium.org/libsodium/releases/
SODIUM_VERSION=libsodium-1.0.18.tar.gz
SODIUM_DOWNLOAD=sodium.tar.gz
SODIUM_FILES=libsodium

# from https://github.com/zeromq/libzmq/releases/tag/
ZMQ_VERSION=v4.3.3/zeromq-4.3.3.tar.gz
ZMQ_DOWNLOAD=zmq.tar.gz
ZMQ_FILES=zmq

# from https://github.com/zeromq/czmq/releases/tag
CZMQ_VERSION=v4.2.0/czmq-4.2.0.tar.gz
CZMQ_DOWNLOAD=czmq.tar.gz
CZMQ_FILES=czmq

rm -rf $DIR/build
mkdir $DIR/build
pushd $DIR/build

echo "downloading libsodium..."
curl -L -o $SODIUM_DOWNLOAD https://download.libsodium.org/libsodium/releases/$SODIUM_VERSION

echo "downloading zeromq..."
curl -L -o $ZMQ_DOWNLOAD https://github.com/zeromq/libzmq/releases/download/$ZMQ_VERSION

echo "downloading czmq..."
curl -L -o $CZMQ_DOWNLOAD https://github.com/zeromq/czmq/releases/download/$CZMQ_VERSION

echo "extracting sodium..."
mkdir $SODIUM_FILES
tar --strip 1 -xvf $SODIUM_DOWNLOAD -C $SODIUM_FILES

echo "extracting zmq..."
mkdir $ZMQ_FILES
tar --strip 1 -xvf $ZMQ_DOWNLOAD -C $ZMQ_FILES

echo "extracting czmq..."
mkdir $CZMQ_FILES
tar --strip 1 -xvf $CZMQ_DOWNLOAD -C $CZMQ_FILES

echo "building libsodium..."
cp $DIR/libsodium.sh $DIR/build/libsodium.sh
bash $DIR/build/libsodium.sh

echo "building zmq..."
cp $DIR/libzmq.sh $DIR/build/libzmq.sh
bash $DIR/build/libzmq.sh

echo "building czmq..."
cp $DIR/libczmq.sh $DIR/build/libczmq.sh
bash $DIR/build/libczmq.sh

# back to the root
popd

echo "cleaning old dist..."
rm -rf $DIR/dist
mkdir $DIR/dist

echo "copy libsodium artifacts..."
cp -R $DIR/build/libsodium_dist dist/libsodium

echo "copy libzmq artifacts..."
cp -R $DIR/build/libzmq_dist dist/libzmq

echo "copy libczmq artifacts..."
cp -R $DIR/build/libczmq_dist dist/libczmq
