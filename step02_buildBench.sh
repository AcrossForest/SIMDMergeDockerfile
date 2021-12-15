toolchain=/root/ModifedGCCForSIMDMerge/armCrossCompiler.cmake 

cd /root
git clone  https://github.com/AcrossForest/BenchmarksForSIMDMerge
mv BenchmarksForSIMDMerge/SpMMBenchmarks .
mv BenchmarksForSIMDMerge/basicProblemExplore .

cd /root/basicProblemExplore
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$toolchain
make all
cd ..

cd /root/SpMMBenchmarks
rm -rf build || true
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make randomGenerator
cp RandomGenerator/randomGenerator ../
cd ..
rm -rf build

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$toolchain
make all
cd ..

cd ..