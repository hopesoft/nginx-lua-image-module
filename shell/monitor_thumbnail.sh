#!/bin/bash
basedir=/home/wwwroot/img.51ajax.com/
hostname=img.51ajax.com
thumbnaildir=thumbnail
excludedir=^${basedir}${thumbnaildir}

/usr/local/bin/inotifywait --exclude $excludedir -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f %e' --event delete,modify  ${basedir} | while read  date time file event
      do
                if [ "${file##*.}" = "jpg" -o "${file##*.}" = "jpeg"  -o "${file##*.}" = "gif" -o "${file##*.}" = "png" ];then
                        case $event in(DELETE|MODIFY)
							tmpfile=${file/$hostname/$hostname\/$thumbnaildir};
							filelist=${tmpfile%.*}_*.${tmpfile##*.};
							for File in $filelist; do
									#echo "rm -rf "$File;
									rm -rf $File
							done
                  ;;
                        esac
                  fi
      done
