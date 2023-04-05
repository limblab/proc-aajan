cd /Volumes/L_MillerLab/data/Jango_12a1/20140829

for dir in /Volumes/L_MillerLab/data/Jango_12a1/20140829/*; do
	# echo "${d}"
	if [ -f ${dir} ]
	then
		d=$(date -r ${dir} +%Y%m%d)
		echo "/Volumes/L_MillerLab/data/Jango_12a1/${d}/"
		mv ${dir} "/Volumes/L_MillerLab/data/Jango_12a1/${d}/"
	fi
done