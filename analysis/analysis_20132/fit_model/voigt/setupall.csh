#!/bin/csh -f

# mkdir part0
# pushd part0
# ln -s ../../primary
# ln -s ../../secondary
# popd

mkdir part1
pushd part1
ln -s ../../primary
ln -s ../../secondary
popd

mkdir part2
pushd part2
ln -s ../../primary
ln -s ../../secondary
popd

mkdir part3
pushd part3
ln -s ../../primary
ln -s ../../secondary
popd

mkdir part4
pushd part4
ln -s ../../primary
ln -s ../../secondary
popd

mkdir part5
pushd part5
ln -s ../../primary
ln -s ../../secondary
popd

mkdir part6
pushd part6
ln -s ../../primary
ln -s ../../secondary
popd

# setup_obsdir part0
setup_obsdir part1
setup_obsdir part2
setup_obsdir part3
setup_obsdir part4
setup_obsdir part5
setup_obsdir part6



