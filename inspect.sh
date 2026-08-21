#!/bin/bash

TARGET_DIR="/tmp/lab_sandbox/etc"
BASELINE_FILE="baseline.txt"

build_baseline(){
echo "Creating Baseline for $TARGET_DIR ..."

find "$TARGET_DIR" -type f | while read -r FILE; do
	PERMISSION=$(stat -c "%a" "$FILE")
	OWNER=$(stat -c "%U:%G" "$FILE")
	HASH=$(sha256sum "$FILE" | awk '{print $1}')

	echo "$FILE | $PERMISSION | $OWNER | $HASH"
done > "$BASELINE_FILE"

echo "Baseline File Created! Baseline Saved to $BASELINE_FILE"
}

check_drift(){
	if [ ! -f "$BASEINE_FILE"]; then
		echo "Error: $BASELINE_FILE not found. try with --build first"
		exit 1
	fi

	echo "Scanning Files For Security Drift ..."
	echo "----------------------------------------"

	while IFS='|' read -r SAVED_FILE SAVED_PERMISSION SAVED_OWNER SAVED_HASH; do
		#deleting whitespaces by using xargs:
		SAVED_FILE=$(echo "$SAVED_FILE" | xargs)
		SAVED_PERMISSION=$(echo "$SAVED_PERMISSION" | xargs)
		SAVED_OWNER=$(echo "$SAVED_OWNER" | xargs)
		SAVED_HASH=$(echo "$SAVED_HASH" | xargs)

		# check if the target file has been deleted:
		if [ ! -f "$SAVED_FILE" ]; then
			echo "[ALERT] DELETED FILE: $SAVED_FILE"
			continue
		fi

		# get the values:
		LIVE_PERMISSION=$(stat -c "%a" "$SAVED_FILE")
		LIVE_OWNER=$(stat -c "%U:%G" "$SAVED_FILE")
		LIVE_HASH=$(sha256sum "$SAVED_FILE" | awk '{print $1}')

		#comparing baseline with live values:
		DRIFT=0

		if [ "$SAVED_PERMISSION" != "$LIVE_PERMISSION" ]; then
			echo "[ALERT] PERMISSION DRIFT: $SAVED_FILE -> EXPECTED: $SAVED_PERMISSION | LIVE -> $LIVE_PERMISSION"
			DRIFT=1
		fi

		if [ "$SAVED_OWNER" != "$LIVE_OWNER" ]; then
			echo "[ALERT] OWNER DRIFT: $SAVED_FILE -> EXPECTED: $SAVED_OWNER | LIVE -> $LIVE_OWNER"
			DRIFT=1
		fi

		if [ "$SAVED_HASH" != "$LIVE_HASH" ]; then
			echo "[ALERT] HASH CHECKSUM DRIFT: $SAVED_FILE -> EXPECTED: $SAVED_HASH | LIVE -> $LIVE_HASH"
			DRIFT=1
		fi
		if [ $DRIFT -eq 0 ]; then
			echo "[OK] $SAVED_FILE"
		fi
	
	done < "$BASELINE_FILE"
}

#flag selector
case "$1" in
	--build)
		build_baseline
		;;
	--check)
		check_drift
		;;
	*)
		echo "Usage: $0 {--build|--check}"
		exit 1
		;;
esac
