#! /bin/bash

#Note that path to adb command must be included in environment variable $PATH.
PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/path/to/adb/command

#Destination folder storing photos. Disk space should be large engough.
save_dest='/path/to/image_folder'

today_date=`date +"%Y%m%d"`
adb start-server
if [ $? -eq 0 ]; then
    echo [`date +"%Y-%m-%d %H:%M:%S"`] adb server running
else
    echo [`date +"%Y-%m-%d %H:%M:%S"`] adb server not running
    exit 
fi

cd $save_dest

#Press Home button.
adb shell "input keyevent KEYCODE_HOME"
sleep 1s

#Launch camera. 
#Note that open_camera_cmd.log is a record of touching events which simulates the effect of touching on the screen's camera icon. May be different against different devices. 
echo [`date +"%Y-%m-%d %H:%M:%S"`] opening camera...
cat open_camera_cmd.log | xargs -l adb shell sendevent
sleep 1s

#Auto focus
echo [`date +"%Y-%m-%d %H:%M:%S"`] focusing....
adb shell "input keyevent KEYCODE_FOCUS"
sleep 1s

#Take a shot
echo [`date +"%Y-%m-%d %H:%M:%S"`] taking a photo...
adb shell "input keyevent KEYCODE_CAMERA"
sleep 4s

#Quit photoing
echo [`date +"%Y-%m-%d %H:%M:%S"`] leaving camera interface...
adb shell "input keyevent KEYCODE_BACK"
sleep 1s

#Location where the photo stored on android device. Device dependent.
img_folder='/storage/sdcard0/DCIM/Camera'

mkdir -p $today_date
echo [`date +"%Y-%m-%d %H:%M:%S"`] try pulling from android device...

#Cut & paste photo from android device to PC 
adb shell ls $img_folder | tr -d '\015' | grep $today_date | while read line; do
    echo [`date +"%Y-%m-%d %H:%M:%S"`] $line saved to $save_dest/$today_date/$line...
    adb pull $img_folder/$line $today_date/$line &> /dev/null
    adb shell rm $img_folder/$line
    echo [`date +"%Y-%m-%d %H:%M:%S"`] $line deleted on device...
    echo
done
