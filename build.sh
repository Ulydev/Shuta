mkdir -p build/release/tmp/
cp -R client/* build/release/tmp/
cp -R shared build/release/tmp/
cp -Rf build/sharedpath.lua build/release/tmp/sharedpath.lua
cd build/release/tmp/
love ../../compile .
zip -r game.love ./*
cd ..
mv tmp/game.love .
rm -r tmp/
