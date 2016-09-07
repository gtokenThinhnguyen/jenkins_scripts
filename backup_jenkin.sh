#!/bin/bash

readonly JENKIN_HOME=$1
readonly DEST_FILE=$2
readonly TMP_DIR="~/data/bakup/jenkins"
readonly ARC_NAME="jenkins-backup"
readonly ARC_DIR="$TMP_DIR/$ARC_NAME"
readonly TMP_TAR_NAME="$TMP_DIR/jenkins_tmp.tar.gz"

mkdir -p "$TMP_DIR"
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
function backupJobs {
	cd "$1"
	tar -cf  $TMP_DIR/jobs.tar . --exclude='./*/workspace/*'
	tar -xf  $TMP_DIR/jobs.tar -C "$2"
	rm -f $TMP_DIR/jobs.tar
}

if [ "$(ls -A $JENKIN_HOME/jobs)" ]; then 
	 backupJobs $JENKIN_HOME/jobs $ARC_DIR/jobs
fi

echo "Compressing files"
cd "$TMP_DIR"
tar -czvf "$TMP_TAR_NAME" "$ARC_NAME"
cd -
mv -f "$TMP_TAR_NAME" "$DEST_FILE"
rm -rf "$ARC_DIR"
