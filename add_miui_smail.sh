#!/bin/bash
#
# Add miui smali files
#
# $1: android original src dir
# $2: miui src dir
# $3: target src dir

BASE_DIR=$1
MIUI_DIR=$2
TARGET_DIR=$3
WORK_DIR=$4
BUILD_OUT=out
OVERLAY_DIR=$PORT_ROOT/android/overlay
OVERLAY_CLASSES=$OVERLAY_DIR/OVERLAY_CLASSES
ADD_CLASSES=$PORT_ROOT/android/miui-add
TMP_ADD=$WORK_DIR/out/tmp_overlay

#$PORT_ROOT/tools/add_miui_methods_and_variables.sh $BASE_DIR $MIUI_DIR $TARGET_DIR
function appendSmaliPart() {
  cp -rf $ADD_CLASSES $TMP_ADD
  if [ -f ./amend_framework_id.sh ];then
    bash ./amend_framework_id.sh $TMP_ADD $TARGET_DIR
  fi
  cd $TMP_ADD
  for file in `find $1 -name *.part`
  do
    filepath=`dirname $file`
    filename=`basename $file .part`
    dstfile="$WORK_DIR/out/$filepath/$filename"
    cat $file >> $dstfile
  done
  cd -
}

if [ $TARGET_DIR = "$BUILD_OUT/framework" ]
then
  appendSmaliPart "framework"
fi

if [ $TARGET_DIR = "$BUILD_OUT/services" ]
then
  appendSmaliPart "services"
fi

if [ $TARGET_DIR = "$BUILD_OUT/telephony-common" ]
then
  appendSmaliPart "telephony-common"
fi

if [ $TARGET_DIR = "$BUILD_OUT/wifi-service" ]
then
  appendSmaliPart "wifi-service"
fi

for class in `cat $OVERLAY_CLASSES | grep -Ev "^$|^#.*$"`
do
    target_smali=$TARGET_DIR/smali/$class.smali
    target_classes=$TARGET_DIR/smali/$class*
    if [ -f "$target_smali" ];then
        rm -f $target_classes
    fi
done


for overlay_smali in `find $OVERLAY_DIR -name "*.smali" | sed 's/\$.*/.smali/' | uniq`
do
    target_smali=${overlay_smali/$OVERLAY_DIR/$TARGET_DIR}
    if [ -f "$target_smali" ];then
        cp -f ${overlay_smali/.smali/}*.smali `dirname $target_smali`
    fi
done


for file in `find $MIUI_DIR -name "*.smali"`
do
        newfile=${file/$MIUI_DIR/$TARGET_DIR}
        if [ ! -f "$newfile" ]
        then
                mkdir -p `dirname $newfile`
                cp $file $newfile
        fi
done

if [ -f "customize_framework.sh" ]; then
	bash ./customize_framework.sh $2 $3
fi
