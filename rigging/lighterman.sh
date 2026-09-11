#!/usr/bin/env bash

gabbard=false

custom_payload=false

custom_payload_path=""

custom_user=false #user that receives the payload on the other side of the scp

custom_user_name="" #TODO unimplemented

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gabbard)
      gabbard=true
      shift
      ;;
    --custom-payload)
      custom_payload=true
      # only take the next arg if it exists and isn't another flag
      custom_payload_path="$2"
      [[ -z "$custom_payload_path" ]] && { echo "--custom_payload requires a value" >&2; exit 1; }
      shift 2
      ;;
    *)
      echo "unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ "$custom_payload" == true && "$gabbard" == true ]]; then
	scp -P 2222 -r "$custom_payload_path" boatswain@localhost:~/
	exit
fi
if [[ "$gabbard" == true ]]; then
	scp -P 2222 -r ~/rigging/ boatswain@localhost:~/
	exit
fi
scp -P 2222 -r ~/rigging/ boatswain@localhost:~/
exit


