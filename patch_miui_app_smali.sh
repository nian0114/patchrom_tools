#!/bin/bash
#
# $1: dir for original miui app
# $2: dir for target miui app
#
if [ -f "customize_miui_app_smali.sh" ]; then
    ./customize_miui_app_smali.sh $1 $2
    if [ $? -ne 0 ];then
       exit 1
    fi
fi

if [ -f $1 ];then

  if [ $1 = "SecurityCenter" ];then
  	#Fix MIUI SecurityCenter icon dislocation
  	sed -i '/- 16/a\sdkInfo:\n  minSdkVersion: '\''23'\''\n  targetSdkVersion: '\''23'\''' $2/apktool.yml
  fi


    # patch *.smali.method under $1
    for file in `find $1 -name "*.smali.method"`; do
        $PORT_ROOT/tools/replace_smali_method.sh apply $file
    done
fi
