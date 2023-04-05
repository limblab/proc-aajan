for dir in /Volumes/L_MillerLab/data/Mihili_12A3_target/*/*merged.ns1; do
	printf '%s\n' "$dir"
	# date=${dir: 44: 8}
	dirnontarget=${dir//_target}
	if [ ! -f ${dirnontarget} ]
	then
	    echo "NEED TO MOVE: Directory ${dirnontarget} does not exist. Moving file."
	    # mv "${dir}" "${dirnontarget}"
	else
	    echo "Directory ${dirnontarget} exists." 
	fi
	# dirnontargetnofilenodate=${dirnontarget: 0: 37}
	# base_name=$(basename ${dir})
	# date=${base_name: 15: 10}
	# newdate=${date//_}
	# echo "${dirnontargetnofilenodate}${newdate}/${base_name}"
	# mv "${dir}" "${dirnontargetnofilenodate}${newdate}/${base_name}"
	# if [[ $dir == *"2014-01-03"* ]]; then
	# 	mv "${dir}" "${dirnontargetnofilenodate}20140103/${base_name}"
	# fi
	# # printf '%s\n' ${dirnontarget}
	# for (( i=0; i<${#base_name}; i++ )); do
	# 	if [[ ${base_name:$i:8} =~ ^[0-9]+$ ]]
	# 	then
	# 		date=${base_name:$i:8}
	# 		if [ ${date: 0: 1} == "0" ]
	# 		then
	# 			mmdd=${date: 0: 4}
	# 			yyyy=${date: 4: 8}
	# 			newdate="${yyyy}${mmdd}"
	# 			mkdir "${dirnontargetnofilenodate}${newdate}/"
	# 			mv "${dir}" "${dirnontargetnofilenodate}${newdate}/"
	# 		else	
	# 			mkdir "${dirnontargetnofilenodate}${date}/"
	# 			mv "${dir}" "${dirnontargetnofilenodate}${date}/"
	# 		fi
	# 		# mkdir ${date}
	# 		# echo "${dirnontargetnofilenodate}${date}/${base_name}"
	# 		# mv "${dir}" "${dirnontargetnofilenodate}${date}/"
	# 		# printf '%s\n'
	# 		break
	# 	fi
	# done
	# date=${base_name: 6: 8}
	# printf '%s\n' "${dirnontargetnofilenodate}${date}/${base_name}"
	# if [ -f ${dirnontargetnofilenodate}${date}/${base_name} ]
	# then
	# 	printf '%s\n' 'File already moved.'
	# else
	# 	printf '%s\n' 'FILE NEEDS TO BE MOVED.'
		# printf '%s\n' "$dir"
		# printf '%s\n' "${dirnontargetnofilenodate}${date}/${base_name}"
		# mv "$dir" "${dirnontargetnofilenodate}${date}"
	# fi
	# # dircsv="${dir}.csv"
	# # printf '%s\n' "$dircsv"
	# # mv "${dir}" "${dircsv}"
	# dirnontarget=${dir//_target}
	# dirnontargetnofile=${dirnontarget: 0: 46}
	# # # date=${dir: -20: 10}
	# # # datedashremoved=${date//-}
	# printf '%s\n' "$dirnontargetnofile"
	# mv "${dir}" "${dirnontarget}"
done