#!/usr/bin/env fish
# Called by Yazi: zip_files.fish file1 file2 ...
# $argv contains the selected absolute file paths

if test (count $argv) -eq 0
    echo "No files provided"
    exit 1
end

# All selected files are in the same directory (Yazi's cwd)
# cd there and use relative names — so zip doesn't embed full paths
set dir (dirname $argv[1])
cd $dir

# Build list of basenames
set names
for path in $argv
    set -a names (basename $path)
end

# Suggest archive name from first file (strip extension)
set default_name (string replace -r '\.[^.]+$' '' $names[1])

read --prompt-str "Archive name [$default_name]: " name
test -n "$name"; or set name $default_name
set name (string replace -r '\.zip$' '' $name)

echo ""
echo "Archiving "(count $names)" file(s) → $name.zip ..."
echo ""

zip -r "$name.zip" $names
and echo ""
and echo "✓ Done: $dir/$name.zip"
or begin
    echo ""
    echo "✗ zip failed"
end

echo ""
read --prompt-str "Press Enter to close..."
