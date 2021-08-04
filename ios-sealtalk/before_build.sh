#!/bin/sh

echo "------sealtalk build start ----------------"
SEALTALK_FRAMEWORKER_PATH="./framework"
if [ ! -d "$SEALTALK_FRAMEWORKER_PATH" ]; then
    mkdir -p "$SEALTALK_FRAMEWORKER_PATH"
fi

#copy imlib
IMLIB_PATH="../ios-imsdk/imlib/bin"
if [ -d "$IMLIB_PATH" ]; then
    echo "sealtalk build: copy imlib"
    SEALTALK_IMLIB_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongIMLib/"
    if [ ! -d $SEALTALK_IMLIB_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_IMLIB_FRAMEWORKER_PATH
    fi
    cp -af ${IMLIB_PATH}/* $SEALTALK_IMLIB_FRAMEWORKER_PATH
fi

#copy imkit
IMKIT_PATH="../ios-imsdk/imkit/bin"
if [ -d "$IMKIT_PATH" ]; then
    echo "sealtalk build: copy imkit"
    SEALTALK_IMKIT_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongIMKit/"
    if [ ! -d $SEALTALK_IMKIT_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_IMKIT_FRAMEWORKER_PATH
    fi
    cp -af ${IMKIT_PATH}/* $SEALTALK_IMKIT_FRAMEWORKER_PATH
fi

#copy contact
CONTACT_PATH="../ios-imsdk/contactcard/bin"
if [ -d "$CONTACT_PATH" ]; then
    echo "sealtalk build: copy contact"
    SEALTALK_CONTACT_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongContactCard/"
    if [ ! -d $SEALTALK_CONTACT_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_CONTACT_FRAMEWORKER_PATH
    fi
    cp -af ${CONTACT_PATH}/* $SEALTALK_CONTACT_FRAMEWORKER_PATH
fi

#copy sight
SIGHT_PATH="../ios-imsdk/sight/bin"
if [ -d "$SIGHT_PATH" ]; then
    echo "sealtalk build: copy sight"
    SEALTALK_SIGHT_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongSight/"
    if [ ! -d $SEALTALK_SIGHT_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_SIGHT_FRAMEWORKER_PATH
    fi
    cp -af ${SIGHT_PATH}/* $SEALTALK_SIGHT_FRAMEWORKER_PATH
fi

#copy sticker
STICKER_PATH="../ios-imsdk/sticker/bin"
if [ -d "$STICKER_PATH" ]; then
    echo "sealtalk build: copy sticker"
    SEALTALK_STICKER_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongSticker/"
    if [ ! -d $SEALTALK_STICKER_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_STICKER_FRAMEWORKER_PATH
    fi
    cp -af ${STICKER_PATH}/* $SEALTALK_STICKER_FRAMEWORKER_PATH
fi



#copy ifly
IFLY_PATH="../ios-imsdk/ifly/bin"
if [ -d "$IFLY_PATH" ]; then
    echo "sealtalk build: copy ifly"
    SEALTALK_IFLY_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongiFlyKit/"
    if [ ! -d $SEALTALK_IFLY_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_IFLY_FRAMEWORKER_PATH
    fi
    cp -af ${IFLY_PATH}/* $SEALTALK_IFLY_FRAMEWORKER_PATH
fi

#copy RongCallKit
CALLKIT_PATH="../ios-rtcsdk/RongCallKit/bin"
if [ -d "$CALLKIT_PATH" ]; then
    echo "sealtalk build: copy callkit"
    SEALTALK_CALLKIT_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongCallKit/"
    if [ ! -d $SEALTALK_CALLKIT_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_CALLKIT_FRAMEWORKER_PATH
    fi
    cp -af ${CALLKIT_PATH}/* $SEALTALK_CALLKIT_FRAMEWORKER_PATH
fi

#copy RongCallLib
CALLLIB_PATH="../ios-rtcsdk/RongCallLib/bin"
if [ -d "$CALLLIB_PATH" ]; then
    echo "sealtalk build: copy callLib"
    SEALTALK_CALLLIB_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongCallLib/"
    if [ ! -d $SEALTALK_CALLLIB_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_CALLLIB_FRAMEWORKER_PATH
    fi
    cp -af ${CALLLIB_PATH}/* $SEALTALK_CALLLIB_FRAMEWORKER_PATH
fi

#copy RongRTCLib
RTCLIB_PATH="../ios-rtcsdk/RongRTCLib/bin"
if [ -d "$RTCLIB_PATH" ]; then
    echo "sealtalk build: copy rtclib"
    SEALTALK_RTCLIB_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongRTCLib/"
    if [ ! -d $SEALTALK_RTCLIB_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_RTCLIB_FRAMEWORKER_PATH
    fi

    cp -af ${RTCLIB_PATH}/* $SEALTALK_RTCLIB_FRAMEWORKER_PATH
fi
