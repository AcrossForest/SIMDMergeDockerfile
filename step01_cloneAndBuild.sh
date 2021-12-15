set -e
cd /root/


echo "Start build gem5"
git clone https://github.com/AcrossForest/ModifiedGem5ForSIMDMerge
cd ModifiedGem5ForSIMDMerge
echo "Finished clone"
source /opt/conda/etc/profile.d/conda.sh
conda activate base
echo "scons is $(which scons)" 
echo "python is $(which python)"
scons ./build/ARM/gem5.opt -j$(nproc) --ignore-style CC=gcc-10 CXX=g++-10 CCFLAGS_EXTRA=-std=c++20 MARSHAL_LDFLAGS_EXTRA=-fno-lto LDFLAGS_EXTRA=-fno-lto PYTHON_CONFIG=/usr/bin/python3-config

echo "Start build gcc"
cd /root/
git clone https://github.com/AcrossForest/ModifedGCCForSIMDMerge
cd ModifedGCCForSIMDMerge
./buildScript.fish buildall