#!/bin/bash

readonly JENKIN_HOME=$1
readonly DEST_FILE=$2
readonly TMP_DIR="/var/lib/jenkins/workspace/Jenkins_Backup"
readonly ARC_NAME="jenkins-backup"
readonly ARC_DIR="$TMP_DIR/$ARC_NAME"
readonly TMP_TAR_NAME="$TMP_DIR/jenkins_tmp.tar.gz"

mkdir -p "$TMP_DIR" 
mkdir -p "$TMP_DIR/data"
rm -rf "$ARC_DIR" "$TMP_TAR_NAME"

echo "Creating jenkins folders"
for i in plugins jobs users secrets nodes;do
	mkdir -p "$ARC_DIR"/$i
done

echo "Backing up xml files"
cp "$JENKIN_HOME"/*.xml "$ARC_DIR"

echo "Backing up plugins"
cp "$JENKIN_HOME/plugins/"*.[hj]pi "$ARC_DIR/plugins"
hpi_pinned_count=$(find $JENKIN_HOME/plugins -name *.hpi.pinned | wc -l)
jpi_pinned_count=$(find $JENKIN_HOME/plugins -name *.jpi.pinned | wc -l)
if [ $hpi_pinned_count  -ne 0 -o $jpi_pinned_count -ne 0 ]; then 
	cp "$JENKIN_HOME/plugins"*.[hj]pi.pinned "$ARC_DIR/plugins" 
fi

echo "Backing up users"
if [ "$(ls -A $JENKIN_HOME/users/)" ]; then
	cp -R "$JENKIN_HOME/users/"* "$ARC_DIR/users"
fi

echo "Backing up secrets"
if [ "$(ls -A $JENKIN_HOME/secrets/)" ]; then
	cp -R "$JENKIN_HOME/secrets/"* "$ARC_DIR/secrets"
fi

echo "Backing up nodes"
if [ "$(ls -A $JENKIN_HOME/nodes/)" ]; then
	cp -R "$JENKIN_HOME/nodes/"* "$ARC_DIR/nodes"
fi


echo "Backing up jenkin jobs"

if [ "$(ls -A $JENKIN_HOME/jobs)" ]; then 
	cd "$JENKIN_HOME/jobs"
	readonly TEMP_TAR="$ARC_DIR/jobs.tar.bz2"
	tar -cf $TEMP_TAR . --exclude='./*/workspace/*'
	tar -xf $TEMP_TAR -C "$ARC_DIR/jobs"
	rm -f $TEMP_TAR
fi

echo "Compressing files"
cd "$TMP_DIR"
tar -czvf "$TMP_TAR_NAME" "$ARC_NAME"
cd -
mv -f "$TMP_TAR_NAME" "$DEST_FILE"
# rm -rf "$ARC_DIR"
