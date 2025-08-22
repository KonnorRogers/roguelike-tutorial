#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1
cd ..
rm -rf ./mygame/vendor/sprite_kit && npx degit konnorrogers/dragonruby-sprite-kit/mygame/lib ./mygame/vendor/sprite_kit --depth 1
