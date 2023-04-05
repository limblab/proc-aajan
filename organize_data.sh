#!/bin/bash

cd /Volumes/L_MillerLab/data/Pop_18E3/Videos/20211009/data/

mkdir Modified_Logfiles
mkdir Modified_Videos
mkdir Original_Logfiles
mkdir Original_Videos
mkdir Duplicated_Frames

for d in /Volumes/L_MillerLab/data/Pop_18E3/Videos/20211009/data/*; do
	# echo "${d}"
	if [ -f ${d} ]
	then
		if [[ $d == *.avi ]]
		then
			printf '%s\n' "$d"
			mv "${d}" "Original_Videos/"

		elif [[ $d == *.mp4 ]]
		then
			printf '%s\n' "$d"
			mv "${d}" "Modified_Videos/"

		elif [[ $d == *"logfile_modified"* ]]
		then
			printf '%s\n' "$d"
			mv "${d}" "Modified_Logfiles/"

		elif [[ $d == *"duplicate"* ]]
		then
			printf '%s\n' "$d"
			mv "${d}" "Duplicated_Frames/"

		else
			printf '%s\n' "$d"
			mv "${d}" "Original_Logfiles/"
		fi
	fi
done