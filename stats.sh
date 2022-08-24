set -eu -o pipefail
#shopt -s extglob

LOGS_DIR=logs

for f in $LOGS_DIR/gcc8*build_kern.log; do
	echo $f;
	# [[ $f =~ .*[0-9]{4}_[0-9]{1,2}_[0-9]{1,2}.* ]] && TEST=${BASH_REMATCH[1]}
	if [[ $f =~ .*([0-9]{4})_([0-9]{1,2})_([0-9]{1,2}).* ]]; then
	       year=${BASH_REMATCH[1]}
	       month=${BASH_REMATCH[2]}
	       day=${BASH_REMATCH[3]}
	       echo $year / $month / $day


	fi

done

