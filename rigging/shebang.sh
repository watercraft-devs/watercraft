#!/usr/bin/env bash
if [[ "$1" == "" ]]; then
	printf "provide the .sh file to add the shebang to as an argument\nUsage: shebang <target.sh>\n"
	exit
fi

sed -i '1{/^#!/!i\
#!/usr/bin/env bash
}' "$@"
