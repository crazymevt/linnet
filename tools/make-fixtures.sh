#!/bin/sh
# Make tests/fixtures/music: a small library of silent, tagged MP3s in
# folders, some with cover art. Needs ffmpeg with libmp3lame.
set -eu
cd "$(dirname "$0")/.."
out=tests/fixtures/music
rm -rf "$out"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cover() { # name colour colour: a soft diagonal gradient with a pale disc
    ffmpeg -loglevel error -y -f lavfi \
        -i "gradients=s=240x240:c0=$2:c1=$3:x0=0:y0=0:x1=240:y1=240:seed=1:speed=0.0001:d=1" \
        -vf "format=rgb24,geq=r='r(X\,Y)+34*lt(hypot(X-160\,Y-82)\,46)':g='g(X\,Y)+34*lt(hypot(X-160\,Y-82)\,46)':b='b(X\,Y)+34*lt(hypot(X-160\,Y-82)\,46)'" \
        -frames:v 1 "$tmp/$1.png"
}

song() { # path seconds title artist album genre year track [cover]
    mkdir -p "$out/$(dirname "$1")"
    if [ -n "${9:-}" ]; then
        ffmpeg -loglevel error -y -f lavfi -i "anullsrc=r=22050:cl=mono" -i "$tmp/$9.png" -t "$2" \
            -map 0:a -map 1:v -c:a libmp3lame -b:a 32k -c:v png -disposition:v attached_pic -id3v2_version 3 \
            -metadata title="$3" -metadata artist="$4" -metadata album="$5" -metadata genre="$6" \
            -metadata date="$7" -metadata track="$8" "$out/$1"
    else
        ffmpeg -loglevel error -y -f lavfi -i "anullsrc=r=22050:cl=mono" -t "$2" \
            -c:a libmp3lame -b:a 32k -id3v2_version 3 \
            -metadata title="$3" -metadata artist="$4" -metadata album="$5" -metadata genre="$6" \
            -metadata date="$7" -metadata track="$8" "$out/$1"
    fi
}

cover dawn "0xf2a65a" "0x3b5ba5"
cover garden "0x9bc472" "0x2f6b4f"
cover hearth "0xe8b04b" "0x8a3b2a"

song "Classical/Marigold Strings - Dawn Suite/01 Morning Light.mp3" 3 "Morning Light" "Marigold Strings" "Dawn Suite" "Classical" 1998 1 dawn
song "Classical/Marigold Strings - Dawn Suite/02 River Song.mp3" 2 "River Song" "Marigold Strings" "Dawn Suite" "Classical" 1998 2 dawn
song "Classical/Marigold Strings - Dawn Suite/03 Evening Hymn.mp3" 2 "Evening Hymn" "Marigold Strings" "Dawn Suite" "Classical" 1998 3 dawn
song "Classical/Piano/Clara Wynn - Garden Waltzes/1 Rose Waltz.mp3" 2 "Rose Waltz" "Clara Wynn" "Garden Waltzes" "Classical" 2004 1 garden
song "Classical/Piano/Clara Wynn - Garden Waltzes/2 Ivy Waltz.mp3" 2 "Ivy Waltz" "Clara Wynn" "Garden Waltzes" "Classical" 2004 2 garden
song "Country/Hearthside Band - Front Porch/01 Front Porch.mp3" 2 "Front Porch" "Hearthside Band" "Front Porch" "Country" 2011 1 hearth
song "Country/Hearthside Band - Front Porch/02 Long Road Home.mp3" 2 "Long Road Home" "Hearthside Band" "Front Porch" "Country" 2011 2 hearth
song "Country/Hearthside Band - Front Porch/03 Sweet Tea.mp3" 2 "Sweet Tea" "Hearthside Band" "Front Porch" "Country" 2011 3 hearth
song "Favourites/Sunday Morning.mp3" 2 "Sunday Morning" "The Evening Choir" "Hymns We Love" "Gospel" 1987 4

# Two versions of one song, tagged alike but with different covers, for
# the test that a cover changed inside a file shows up (VLC caches covers
# by artist and album).
cover before "0x5a5a5a" "0x9a9a9a"
cover after "0xe0457b" "0x5b2a86"
changed=tests/fixtures/changed-cover
rm -rf "$changed"; mkdir -p "$changed"
for v in before after; do
    ffmpeg -loglevel error -y -f lavfi -i "anullsrc=r=22050:cl=mono" -i "$tmp/$v.png" -t 1 \
        -map 0:a -map 1:v -c:a libmp3lame -b:a 32k -c:v png -disposition:v attached_pic -id3v2_version 3 \
        -metadata title="Changing Song" -metadata artist="Cover Test Band" -metadata album="Two Covers" \
        "$changed/$v.mp3"
done

# A file with no tags at all: the library names it by its file name.
mkdir -p "$out/Favourites"
ffmpeg -loglevel error -y -f lavfi -i "anullsrc=r=22050:cl=mono" -t 2 -c:a libmp3lame -b:a 32k \
    -map_metadata -1 -write_xing 0 "$out/Favourites/Grandpa's Tune.mp3"
# Not music: the scan leaves these out.
printf 'notes\n' > "$out/Favourites/notes.txt"
printf 'x' > "$out/Favourites/._Sunday Morning.mp3"
