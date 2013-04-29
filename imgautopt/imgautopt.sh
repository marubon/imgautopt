#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2013 Daisuke Maruyama
# https://github.com/marubon
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

##############################################################################
# Script Name: imageoptim.sh
# Description: A script to resize and compress images on current directory
# Usage: imageoptim.sh <RESAMPLING WIDTH>
# Param: RESAMPLING WIDTH target width for resized image
##############################################################################


OUTPUT_DIR=./output
BASE_DIR=.
LOG_DIR=./log
CMDNAME=`basename $0`
PNG_NUM_COLOR=256
PNG_COMP_SPEED=1

# Function: LOG()
# Description: Common function to output log message
# Usage: LOG <LOG_LEVEL> <LOG_MESSAGE>
# Param: LOG_LEVEL log message level (INFO,ERROR,WARN)
LOG(){
    LOG_LEVEL=$1
    LOG_MESSAGE=$2
    LOG_DATE=`date '+%Y-%m-%d'`
    LOG_TIME=`date '+%T'`
    LOG_FILE="${LOG_DIR}/`basename $0 .sh`_`date '+%Y-%m-%d'`.log"

    if [ ! -a ${LOG_FILE} ]; then
        touch ${LOG_FILE} > /dev/null 2>&1
    fi

    echo "${LOG_DATE} ${LOG_TIME} [${LOG_LEVEL}] ${CMDNAME} ${LOG_MESSAGE}"
    echo "${LOG_DATE} ${LOG_TIME} [${LOG_LEVEL}] ${CMDNAME} ${LOG_MESSAGE}" >> ${LOG_FILE}

    return 0
}

PERCENT(){
    echo $(bc <<< "scale=2; (($1/$2)*100)")
}

DIFFERENCE(){
    echo $(bc <<< "scale=3; $1-$2")
}

SIZE_IN_BYTE(){
    echo `stat -f %z $1`
}

SIZE_IN_KBYTE(){
    echo $(bc <<< "scale=3; $1/1000")
}

FORMAT_NUM(){
    #awk '{printf"%\047d\n",$1}' <<< "1000000"
    #printf "%'d\n" "1000000"
    printf "%'.3f\n" $1
}

# Function: IMG_RESIZE()
# Description: function to resize images based on specified resampling width
# Usage: IMG_RESIZE <FILE> <RESIZE_WIDTH> <OUTPUT_DIR>
# Param: FILE file path
# Param: RESIZE_WIDTH resampling width
# Param: OUTPUT_DIR output directory for deploying resized images
IMG_RESIZE(){
    FILE=$1
    FILE_NAME=`basename ${FILE}`
    RESIZE_WIDTH=$2
    OUTPUT_DIR=$3
    ABS_OUTPUT_DIR=$(cd ${OUTPUT_DIR} && pwd)

    sips --resampleWidth ${RESIZE_WIDTH} ${FILE} --out ${ABS_OUTPUT_DIR} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        ORIGINAL_SIZE_BYTE=`SIZE_IN_BYTE ${FILE}`
        RESIZE_SIZE_BYTE=`SIZE_IN_BYTE ${OUTPUT_DIR}/${FILE_NAME}`

        ORIGINAL_SIZE_KBYTE=`SIZE_IN_KBYTE ${ORIGINAL_SIZE_BYTE}`
        RESIZE_SIZE_KBYTE=`SIZE_IN_KBYTE ${RESIZE_SIZE_BYTE}`

        DIFFERENCE_SIZE_BYTE=`DIFFERENCE ${RESIZE_SIZE_BYTE} ${ORIGINAL_SIZE_BYTE}`
        DIFFERENCE_SIZE_KBYTE=`SIZE_IN_KBYTE ${DIFFERENCE_SIZE_BYTE}`


        RESIZED_RATE=`PERCENT ${RESIZE_SIZE_BYTE} ${ORIGINAL_SIZE_BYTE}`

        LOG "INFO" "[RESIZE] ${FILE_NAME} `FORMAT_NUM ${ORIGINAL_SIZE_KBYTE}`kb `FORMAT_NUM ${RESIZE_SIZE_KBYTE}`kb `FORMAT_NUM ${DIFFERENCE_SIZE_KBYTE}`kb -`DIFFERENCE 100 ${RESIZED_RATE}`%"
        return 0
    elif [ $? -ne 0 ]; then
        LOG "ERROR" "Image resizing failed: ${FILE_NAME}"
        return 1
    fi
}


# Function: PNG_COMP()
# Description: function to compress PNG images based on specified speed and number of colors
# Usage: PNG_COMP <FILE> <COMP_SPEED> <NUM_COLOR>
# Param: FILE file path
# Param: COMP_SPEED compression speed
# Param: NUM_COLOR number of color to use
PNG_COMP(){
    FILE=$1
    FILE_NAME=`basename ${FILE}`
    COMP_SPEED=$2
    NUM_COLOR=$3

    ORIGINAL_SIZE_BYTE=`SIZE_IN_BYTE ${FILE}`

    pngquant --speed ${COMP_SPEED} --force --ext .png ${NUM_COLOR} ${FILE} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        COMPRESSED_SIZE_BYTE=`SIZE_IN_BYTE ${FILE}`
        ORIGINAL_SIZE_KBYTE=`SIZE_IN_KBYTE ${ORIGINAL_SIZE_BYTE}`

        COMPRESSED_SIZE_KBYTE=`SIZE_IN_KBYTE ${COMPRESSED_SIZE_BYTE}`

        DIFFERENCE_SIZE_BYTE=`DIFFERENCE ${COMPRESSED_SIZE_BYTE} ${ORIGINAL_SIZE_BYTE}`
        DIFFERENCE_SIZE_KBYTE=`SIZE_IN_KBYTE ${DIFFERENCE_SIZE_BYTE}`

        COMPRESSED_RATE=`PERCENT ${COMPRESSED_SIZE_BYTE} ${ORIGINAL_SIZE_BYTE}`

        LOG "INFO" "[COMPRESS] ${FILE_NAME} `FORMAT_NUM ${ORIGINAL_SIZE_KBYTE}`kb `FORMAT_NUM ${COMPRESSED_SIZE_KBYTE}`kb `FORMAT_NUM ${DIFFERENCE_SIZE_KBYTE}`kb -`DIFFERENCE 100 ${COMPRESSED_RATE}`%"

        return 0
    elif [ $? -ne 0 ]; then
        LOG "INFO" "Image compression failed: ${FILE_NAME}"
#rm ${OUTPUT_DIR}/*.png
        LOG "ERROR" "[END] abnormal exit status 1"
        return 1
fi

}

# Function: PNG_COMP()
# Description: function to compress PNG images based on specified speed and number of colors
# Usage: PNG_COMP <FILE> <COMP_SPEED> <NUM_COLOR>
# Param: FILE file path
# Param: COMP_SPEED compression speed
# Param: NUM_COLOR number of color to use
#JPEG_COMP(){
#
#}

#if [ $# -ne 1 ]; then
#    echo "Usage: $CMDNAME <resample width>" 1>&2
#    exit 1
#fi

RESIZE_WIDTH=$1

LOG "INFO" "[START SCRIPT]"

#if [ test "#{RESIZE_WIDTH" == "" ]; then
#	echo "[ERROR] Resampling width of image is not set."
#	exit 1
#fi

# Confirm output directory existence
if [ ! -d ${OUTPUT_DIR} ]; then

mkdir -p ${OUTPUT_DIR} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    LOG "ERROR" "Output directory creation failed."
    LOG "ERROR" "[END] Abnormal exit status 1"
    exit 1;
fi
fi

# Confirm log directory existence
if [ ! -d ${LOG_DIR} ]; then

    mkdir ${LOG_DIR} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        LOG "ERROR" "Output directory creation failed."
        LOG "ERROR" "[END] Abnormal exit status 1"
    exit 1;
    fi
fi

# Confirm PNG file existence
NUM_TARGET_PNG=`ls ${BASE_DIR}/*.png | wc -l` > /dev/null 2>&1
if [ ! ${NUM_TARGET_PNG} -gt 0 ]; then
    LOG "ERROR" "PNG file does not exist."
    LOG "ERROR" "[END] Abnormal exit status 1"
    exit 1
fi

# Resize PNG file using sips command based on specified resamping width
for FILE in `ls -1 ${BASE_DIR}/*.png`;
do
    IMG_RESIZE "${FILE}" "${RESIZE_WIDTH}" "${OUTPUT_DIR}"
done

# Confirm resized image (i.e. compression target images) existence
NUM_RESIZED_IMAGE=`find ${OUTPUT_DIR} -type f | wc -c`
if [ ! ${NUM_RESIZED_IMAGE} -gt 0 ]; then
    LOG "ERROR" "There are no compression target images in ${OUTPUT_DIR}"
    LOG "ERROR" "[END] Abnormal exit status 1"
    exit 1
fi

# Compress PNG file using pngquant command
for FILE in `ls -1 ${OUTPUT_DIR}/*.png`;
do
    PNG_COMP "${FILE}" 1 256
done

LOG "INFO" "[END SCRIPT] Normal exit status 0"

exit 0