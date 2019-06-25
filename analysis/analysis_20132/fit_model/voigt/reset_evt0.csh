#!/bin/csh -f

pushd part0
rm -rf evt0
ln -s ../part0_evt1.fits ./evt0
popd

pushd part1
rm -rf evt0
ln -s ../part1_evt1.fits ./evt0
popd

pushd part2
rm -rf evt0
ln -s ../part2_evt1.fits ./evt0
popd

pushd part3
rm -rf evt0
ln -s ../part3_evt1.fits ./evt0
popd

pushd part4
rm -rf evt0
ln -s ../part4_evt1.fits ./evt0
popd

pushd part5
rm -rf evt0
ln -s ../part5_evt1.fits ./evt0
popd

pushd part6
rm -rf evt0
ln -s ../part6_evt1.fits ./evt0
popd

