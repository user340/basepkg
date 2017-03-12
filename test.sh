for i in `ls base`
do
	if [ -d ./base/$i ]; then
		grep -E "^$i" database/deps 
	fi
done
