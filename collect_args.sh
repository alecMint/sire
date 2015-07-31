
aptUpdate=1
argi=0
for arg in "$@"; do
	target=`echo "$arg" | sed -n 's/^--target=\(.*\)/\1/p'`
	if [ "$target" ]; then
		serverNameOverride=$target
	elif [ "$arg" == '-na' ]; then
		aptUpdate=0
	else
		envs[$argi]=$arg
		((argi++))
	fi
done
echo "envs: ${envs[@]}"
if [ "$serverNameOverride" ]; then echo "serverNameOverride: $serverNameOverride"; fi
echo "aptUpdate: $aptUpdate"

export envs
export serverNameOverride
export aptUpdate
