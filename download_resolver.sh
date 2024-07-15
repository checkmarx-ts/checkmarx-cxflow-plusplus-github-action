#!/bin/bash


if [ "$1" == "" ]; then
    >&2 echo Arg1 is missing, please supply temp root.
    exit 255
fi

if [ "$2" == "" ]; then
    >&2 echo Arg2 is missing, please supply os type: windows, glib, musl, macos
    exit 255
fi

TEMP_DIR=$(mktemp -d -p $1)

case $2 in
    windows)
    DOWNLOAD_URL="https://sca-downloads.s3.amazonaws.com/cli/latest/ScaResolver-win64.zip"
    DOWNLOAD_OUTPUT_PATH="$TEMP_DIR/resolver.zip"
    UNZIP_CMD=(unzip $DOWNLOAD_OUTPUT_PATH -d $TEMP_DIR)
    ;;

    glib)
    DOWNLOAD_URL="https://sca-downloads.s3.amazonaws.com/cli/latest/ScaResolver-linux64.tar.gz"
    DOWNLOAD_OUTPUT_PATH="$TEMP_DIR/resolver.tgz"
    UNZIP_CMD=(tar -C $TEMP_DIR -xzf $DOWNLOAD_OUTPUT_PATH)
    ;;

    musl)
    DOWNLOAD_URL="https://sca-downloads.s3.amazonaws.com/cli/latest/ScaResolver-musl64.tar.gz"
    DOWNLOAD_OUTPUT_PATH="$TEMP_DIR/resolver.tgz"
    UNZIP_CMD=(tar -C $TEMP_DIR -xzf $DOWNLOAD_OUTPUT_PATH)
    ;;

    macos)
    DOWNLOAD_URL="https://sca-downloads.s3.amazonaws.com/cli/latest/ScaResolver-macos64.tar.gz"
    DOWNLOAD_OUTPUT_PATH="$TEMP_DIR/resolver.tgz"
    UNZIP_CMD=(tar -C $TEMP_DIR -xzf $DOWNLOAD_OUTPUT_PATH)
    ;;


    *)
    >&2 echo Unknown OS: $2
    rm -rf $TEMP_DIR
    exit 255
    ;;
esac


[ -x "$(command -v curl)" ] && curl $DOWNLOAD_URL -s -o $DOWNLOAD_OUTPUT_PATH || :
[ -x "$(command -v wget)" -a ! -f "$DOWNLOAD_OUTPUT_PATH" ] && wget -q $DOWNLOAD_URL -O $DOWNLOAD_OUTPUT_PATH || :
[ ! -f "$DOWNLOAD_OUTPUT_PATH" ] && (echo Could not find curl or wget ; rm -rf $TEMP_DIR ; exit 255) || :

"${UNZIP_CMD[@]}"

echo $TEMP_DIR
exit 0
