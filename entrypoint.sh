#!/bin/bash -l

# usage:
# comma separation required
# dont use spaces unless they're the export name
# then use quotes e.g. 'Android x86'

set -e

mkdir -p ./$2/builds
mkdir -p ~/.local/share/godot/templates
mkdir -p ~/.config/godot/

# need to move templates and init android settings from docker image
mv /root/.local/share/godot/templates/* ~/.local/share/godot/templates
mv /root/.config/godot/editor_settings-3.tres ~/.config/godot/

IFS=','
export_mode=export-debug

if [ $3 != "true" ] ; then
    export_mode=export
fi

read -a strarr <<< "$1"



for i in "${strarr[@]}"
do
    # need to remove spaces/quotes/slashes for filename
    removed_quotes=$(echo "$i" | tr -d \'\"\\\/ | tr -d '\040\011\012\015')
    $i="$(echo "$i" | tr -d \'\")"
    # doesnt matter if $2 has a trailing slash already
    godot --$export_mode ${i} builds/$removed_quotes-build.zip --path ./$2 -v
    # debug command
    # touch builds/$removed_quotes-build.zip
done

# place all builds into a builds.zip file so we only have one zipped output
# that can be unzipped directly to builds, and not builds/something-build.zip
if [[ ${#strarr[@]} > 1 ]] ; then
    cd ./$2/builds/
    rm -f builds.zip ||:
    zip -r ../builds.zip . -i *
    mv ../builds.zip ./builds.zip
    cd ../
else
    # intended to fail here if there were no builds created
    mv builds/$removed_quotes-build.zip builds/builds.zip
fi
#outputting all the builds into a single zip
echo ::set-output name=builds::builds/builds.zip