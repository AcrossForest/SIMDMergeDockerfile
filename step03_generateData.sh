cd /root/basicProblemExplore

cd SetOperation
python generateMerge.py 10000_o_5000.bin 10000 10000 5000
cd ..

cd JoinOp
python generateKV.py 10000_o_5000.bin 10000 10000 5000
cd ..

cd ComplexJoin
python randSparseTensor.py 1 1 10000 0.5 vector_real.bin
python randSparseTensor.py 2 1 10000 0.5 matrix_real.bin
python randSparseTensor.py 3 1 10000 0.5 tensor_real.bin
python randSparseTensor.py 1 2 10000 0.5 vector_complex.bin
python randSparseTensor.py 2 2 10000 0.5 matrix_complex.bin
python randSparseTensor.py 3 2 10000 0.5 tensor_complex.bin
cd ..

cd /root/SpMMBenchmarks
python ./Workflow/middleExpand.py makeMat makeWorkload
