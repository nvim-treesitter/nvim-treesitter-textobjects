#!/usr/bin/env bash

SOURCE_DIR=$(dirname "$0")

# Download tests
TEMPDIR=$(mktemp -d)
wget --content-disposition 'https://uoe-my.sharepoint.com/:u:/g/personal/s1884147_ed_ac_uk/EfuU0bWSgopAgZiq9ykpLjsBf7CM95TkRDa4SxM-N4CSXg?e=YzXmhQ&download=1' -P "$TEMPDIR" &> /dev/null

FILE=$(ls "$TEMPDIR")
tar xvfz "$TEMPDIR/$FILE" -C "$TEMPDIR" &> /dev/null

tests_path=$(ls "$TEMPDIR"/*.yaml)

while read -r test_yaml_path; do
	python "$SOURCE_DIR/run_test_yaml.py" "$test_yaml_path"
done <<< "$tests_path"

rm -rf "$TEMPDIR"
