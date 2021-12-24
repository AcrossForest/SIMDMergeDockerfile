# Step-by-step guide to reproduce the experiment result
We will reproduce the result of the following figures:
+ Figure 11: the merge-style-operation on various set-operation and join-operation
+ Figure 12: the merge-style-operation on scientific computing
+ Figure 14: the sorting
+ Figure 15: the performance of SpGEMM

Reproducing the result for Figure 11,12,14 is fast. Figure 15 will take a lot of time.

Before running any following code, please run the following script to generate input data and setup the environment variables.
```bash
bash step03_generateData.sh
source step04_setupEnvs.sh
# otherwise you see the following error message later
# "Please provide environment variable GEM5PATH (the path to gem5.opt) and GEM5SEPATH (the path to gem5's script se.py)"
```

## Figure 11
Figure 11 consists of several kernels:
+ Set-Union: find the union of two sorted sets ($A \cup B$)
+ Set-Intersection: find the intersection of two sorted sets ($A \cap B$)
+ Set-XOR: find the symmetric difference of two sorted sets ($A xor B$)
+ Set-Diff: find the difference of two sorted sets ($A-B$)
+ Join-Full-Outer: similar to set-Union, but on two sorted dictionaries. The value of output is the tuple of two inputs.
+ Join-Inner: similar to set-Intersection, but on two sorted dictionaries. The value of output is the tuple of two inputs.
+ Join-Outer-Excluding: similar to Set-XOR in a way like Join-Inner to Set-Intersection
+ Join-Left-Excluding: similar to Set-Diff
+ Join-Left: given two sorted dictionaries, match the keys of B to the keys of A, and make tuple to be the value part of the output

In both cases, the baseline is scalar implementation, and the proposed SIMD primitives make it possible to be implemented using SIMD. As Figure-11 shows, for each kernel, we report one result of the scalar implementation, and 5 results for SIMD implementation with different assumptions on the SIMD width that the CPU provides. For example, "SIMD 4" means the CPU has a 128bit SIMD unit (e.g. x86 SSE, arm neon), and "SIMD X" for X = 4,8,16,32,64 means X*32bit SIMD unit. 

## First half: Set-{Union,Intersection,XOR,Diff}

To obtain the results, run the binary ``SetOperation''. For example, to test SIMD width 16, run following:
```bash
SIMD_WIDTH=16 # repeat and let SIMD_WITDH to take all 5 values {4, 8, 16, 32, 64}
SCALAR_REPEAT=5 # the number of repeats executions for scalar (baseline) to take
SIMD_REPEAT=5 # the number of repeats executions for simd (proposed) to take

cd /root/basicProblemExplore/
python gem5ArmRunner.py ${SIMD_WIDTH} SetOperation file SetOperation/10000_o_5000.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}
```

You are expected to see the following results (your numbers will be almost the same, but the random number generation for the input data might cause the last digit to be slightly different.):
```
Load a: 10000
Load b: 10000
Result match
Result match
Result match
Result match
[   Union Scalar]       mean =   1.32e+05(ns)   sd =   3.18e+02(ns)     nsample =     5
[     Union SIMD]       mean =   1.67e+04(ns)   sd =   8.78e+01(ns)     nsample =     5
[Intersect Scalar]      mean =   1.31e+05(ns)   sd =   1.01e+03(ns)     nsample =     5
[ Intersect SIMD]       mean =   1.46e+04(ns)   sd =   7.66e+01(ns)     nsample =     5
[     XOR Scalar]       mean =   1.32e+05(ns)   sd =   2.60e+02(ns)     nsample =     5
[       XOR SIMD]       mean =   1.66e+04(ns)   sd =   4.03e+02(ns)     nsample =     5
[    Diff Scalar]       mean =   1.29e+05(ns)   sd =   2.54e+02(ns)     nsample =     5
[      Diff SIMD]       mean =   1.49e+04(ns)   sd =   7.69e+01(ns)     nsample =     5
```

Here, for example, "Union Scalar" is the execution time of set-union of baseline, and "Union SIMD" is the execution time of proposed solution *FOR SIMD 16*. To obtain the results for other SIMD width, you need to set *SIMD_WIDTH* in above base code snippet to other values {4,8,16,32,64}. Because changing the SIMD width dose not influcence the scalar baseline performance,  you will found the execution time of "{kernel name} Scalar" dose not change for different *SIMD_WIDTH* and you only need to collect once. (So you can set SCALAR_REPEAT=1 starting from the second SIMD_WIDTH to save some running time).

## Second half: Join-{Inner,Full-Outer,Outer-Excluding,Left-Exluding,Left}
Run the binary JoinOp. For example, to test SIMD width 16, run following:
```bash
SIMD_WIDTH=4 # repeat and let SIMD_WITDH to take all 5 values {4, 8, 16, 32, 64}
SCALAR_REPEAT=5 # the number of repeated executions for scalar (baseline) to take avarage
SIMD_REPEAT=5 # the number of repeated executions for simd (proposed) to take avarage

cd /root/basicProblemExplore/
python gem5ArmRunner.py ${SIMD_WIDTH} JoinOp file JoinOp/10000_o_5000.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}
```

You are expected to see the following results:
```
Load aidx: 9999
Load aval: 10000
Load bidx: 10000
Load bval: 10000
For Join-Inner - join, g_lenc =  5000
Correct!
For Join-Outer-Ex - join, g_lenc =  9999
Correct!
For Join-Left-Ex - join, g_lenc =  4999
Correct!
For Join-Left - join, g_lenc =  9999
Correct!
[Join-Full-Outer Scalar]        mean =   1.58e+05(ns)   sd =   2.93e+02(ns)     nsample =     5
[Join-Full-Outer SIMD]  mean =   2.46e+04(ns)   sd =   1.30e+02(ns)     nsample =     5
[Join-Inner Scalar]     mean =   1.44e+05(ns)   sd =   1.71e+02(ns)     nsample =     5
[Join-Inner SIMD]       mean =   1.75e+04(ns)   sd =   1.31e+02(ns)     nsample =     5
[Join-Outer-Ex Scalar]  mean =   1.52e+05(ns)   sd =   2.81e+02(ns)     nsample =     5
[Join-Outer-Ex SIMD]    mean =   2.15e+04(ns)   sd =   5.28e+02(ns)     nsample =     5
[Join-Left-Ex Scalar]   mean =   1.35e+05(ns)   sd =   2.44e+02(ns)     nsample =     5
[Join-Left-Ex SIMD]     mean =   1.84e+04(ns)   sd =   1.14e+02(ns)     nsample =     5
[Join-Left Scalar]      mean =   1.51e+05(ns)   sd =   1.39e+03(ns)     nsample =     5
[ Join-Left SIMD]       mean =   1.84e+04(ns)   sd =   1.08e+02(ns)     nsample =     5
```
Similar to the scenario of above SetOperation, you need to *SIMD_WIDTH* to other values {4,8,16,32,64} to collect the results for different CPU SIMD width settings, but you only need to collect the result fo scalar baseline once (their results do not change with *SIMD_WIDTH*).

## Calculate the throughput
When you finished all of them, you are likely to obtain the following results after adjusting their order so that the results for Scalar and SIMD x are gathered together: 
```
[   Union Scalar]       mean =   1.32e+05(ns)   sd =   3.18e+02(ns)     nsample =     5 // Scalar baseline (from any SIMD length)
[Intersect Scalar]      mean =   1.31e+05(ns)   sd =   1.01e+03(ns)     nsample =     5 // Scalar baseline (from any SIMD length)
[     XOR Scalar]       mean =   1.32e+05(ns)   sd =   2.60e+02(ns)     nsample =     5 // Scalar baseline (from any SIMD length)
[    Diff Scalar]       mean =   1.29e+05(ns)   sd =   2.54e+02(ns)     nsample =     5 // Scalar baseline (from any SIMD length)
[Join-Full-Outer Scalar]        mean =   1.58e+05(ns)   sd =   2.93e+02(ns)     nsample =     5 // Scalar baseline (from any SIMD length)
[Join-Inner Scalar]     mean =   1.44e+05(ns)   sd =   1.71e+02(ns)     nsample =     5 // Scalar baseline (from any SIMD length)
[Join-Outer-Ex Scalar]  mean =   1.52e+05(ns)   sd =   2.81e+02(ns)     nsample =     5 // Scalar baseline (from any SIMD length)
[Join-Left-Ex Scalar]   mean =   1.35e+05(ns)   sd =   2.44e+02(ns)     nsample =     5 // Scalar baseline (from any SIMD length)
[Join-Left Scalar]      mean =   1.51e+05(ns)   sd =   1.39e+03(ns)     nsample =     5 // Scalar baseline (from any SIMD length)

[     Union SIMD]       mean =   6.73e+04(ns)   sd =   4.30e+02(ns)     nsample =     5 // when setting SIMD 4
[ Intersect SIMD]       mean =   5.48e+04(ns)   sd =   7.65e+02(ns)     nsample =     5 // when setting SIMD 4
[       XOR SIMD]       mean =   5.84e+04(ns)   sd =   6.68e+02(ns)     nsample =     5 // when setting SIMD 4
[      Diff SIMD]       mean =   5.58e+04(ns)   sd =   7.83e+01(ns)     nsample =     5 // when setting SIMD 4
[Join-Full-Outer SIMD]  mean =   9.39e+04(ns)   sd =   6.88e+02(ns)     nsample =     5 // when setting SIMD 4
[Join-Inner SIMD]       mean =   6.34e+04(ns)   sd =   1.36e+02(ns)     nsample =     5 // when setting SIMD 4
[Join-Outer-Ex SIMD]    mean =   7.51e+04(ns)   sd =   7.69e+02(ns)     nsample =     5 // when setting SIMD 4
[Join-Left-Ex SIMD]     mean =   6.71e+04(ns)   sd =   1.17e+02(ns)     nsample =     5 // when setting SIMD 4
[ Join-Left SIMD]       mean =   6.70e+04(ns)   sd =   1.12e+02(ns)     nsample =     5 // when setting SIMD 4

[     Union SIMD]       mean =   3.25e+04(ns)   sd =   2.50e+02(ns)     nsample =     5 // when setting SIMD 8
[ Intersect SIMD]       mean =   2.77e+04(ns)   sd =   7.73e+01(ns)     nsample =     5 // when setting SIMD 8
[       XOR SIMD]       mean =   3.08e+04(ns)   sd =   4.87e+02(ns)     nsample =     5 // when setting SIMD 8
[      Diff SIMD]       mean =   2.84e+04(ns)   sd =   7.28e+01(ns)     nsample =     5 // when setting SIMD 8
[Join-Full-Outer SIMD]  mean =   4.74e+04(ns)   sd =   3.33e+02(ns)     nsample =     5 // when setting SIMD 8
[Join-Inner SIMD]       mean =   3.32e+04(ns)   sd =   1.34e+02(ns)     nsample =     5 // when setting SIMD 8
[Join-Outer-Ex SIMD]    mean =   4.04e+04(ns)   sd =   6.72e+02(ns)     nsample =     5 // when setting SIMD 8
[Join-Left-Ex SIMD]     mean =   3.53e+04(ns)   sd =   1.16e+02(ns)     nsample =     5 // when setting SIMD 8
[ Join-Left SIMD]       mean =   3.53e+04(ns)   sd =   1.12e+02(ns)     nsample =     5 // when setting SIMD 8

[     Union SIMD]       mean =   1.67e+04(ns)   sd =   8.78e+01(ns)     nsample =     5 // when setting SIMD 16 // <- example
[ Intersect SIMD]       mean =   1.46e+04(ns)   sd =   7.66e+01(ns)     nsample =     5 // when setting SIMD 16
[       XOR SIMD]       mean =   1.66e+04(ns)   sd =   4.03e+02(ns)     nsample =     5 // when setting SIMD 16
[      Diff SIMD]       mean =   1.49e+04(ns)   sd =   7.69e+01(ns)     nsample =     5 // when setting SIMD 16
[Join-Full-Outer SIMD]  mean =   2.46e+04(ns)   sd =   1.30e+02(ns)     nsample =     5 // when setting SIMD 16
[Join-Inner SIMD]       mean =   1.75e+04(ns)   sd =   1.31e+02(ns)     nsample =     5 // when setting SIMD 16
[Join-Outer-Ex SIMD]    mean =   2.15e+04(ns)   sd =   5.28e+02(ns)     nsample =     5 // when setting SIMD 16
[Join-Left-Ex SIMD]     mean =   1.84e+04(ns)   sd =   1.14e+02(ns)     nsample =     5 // when setting SIMD 16
[ Join-Left SIMD]       mean =   1.84e+04(ns)   sd =   1.08e+02(ns)     nsample =     5 // when setting SIMD 16

[     Union SIMD]       mean =   8.99e+03(ns)   sd =   6.37e+01(ns)     nsample =     5 // when setting SIMD 32
[ Intersect SIMD]       mean =   7.82e+03(ns)   sd =   7.50e+01(ns)     nsample =     5 // when setting SIMD 32
[       XOR SIMD]       mean =   8.88e+03(ns)   sd =   2.81e+02(ns)     nsample =     5 // when setting SIMD 32
[      Diff SIMD]       mean =   7.99e+03(ns)   sd =   6.72e+01(ns)     nsample =     5 // when setting SIMD 32
[Join-Full-Outer SIMD]  mean =   1.29e+04(ns)   sd =   7.09e+01(ns)     nsample =     5 // when setting SIMD 32
[Join-Inner SIMD]       mean =   9.46e+03(ns)   sd =   1.27e+02(ns)     nsample =     5 // when setting SIMD 32
[Join-Outer-Ex SIMD]    mean =   1.16e+04(ns)   sd =   4.25e+02(ns)     nsample =     5 // when setting SIMD 32
[Join-Left-Ex SIMD]     mean =   9.85e+03(ns)   sd =   1.10e+02(ns)     nsample =     5 // when setting SIMD 32
[ Join-Left SIMD]       mean =   9.85e+03(ns)   sd =   1.03e+02(ns)     nsample =     5 // when setting SIMD 32

[     Union SIMD]       mean =   4.91e+03(ns)   sd =   6.00e+01(ns)     nsample =     5 // when setting SIMD 64
[ Intersect SIMD]       mean =   4.23e+03(ns)   sd =   7.27e+01(ns)     nsample =     5 // when setting SIMD 64
[       XOR SIMD]       mean =   4.91e+03(ns)   sd =   2.45e+02(ns)     nsample =     5 // when setting SIMD 64
[      Diff SIMD]       mean =   4.32e+03(ns)   sd =   6.66e+01(ns)     nsample =     5 // when setting SIMD 64
[Join-Full-Outer SIMD]  mean =   1.16e+04(ns)   sd =   5.10e+01(ns)     nsample =     5 // when setting SIMD 64
[Join-Inner SIMD]       mean =   7.28e+03(ns)   sd =   8.04e+01(ns)     nsample =     5 // when setting SIMD 64
[Join-Outer-Ex SIMD]    mean =   9.47e+03(ns)   sd =   3.46e+01(ns)     nsample =     5 // when setting SIMD 64
[Join-Left-Ex SIMD]     mean =   7.26e+03(ns)   sd =   5.73e+01(ns)     nsample =     5 // when setting SIMD 64
[ Join-Left SIMD]       mean =   9.55e+03(ns)   sd =   6.26e+01(ns)     nsample =     5 // when setting SIMD 64

```

Now, we can compute the throughput using execution time. Throughput=((size(a) + size(b))/execution time) where size(a) and size(b) are the number of elements of two inputs, which are both 10k in our experiments. So the throughput=((10000 + 10000)/execution time). We can then draw Figure 11 using the above throughputs. For example, for Set-Union problem, the throughput of our proposed method for SIMD 16 is calculated based on the following record:
[     Union SIMD]       mean =   1.67e+04(ns)   sd =   8.78e+01(ns)     nsample =     5 // when setting SIMD 16 // <- example
So the thoughput is (10000 + 10000)/1.67e+04 = 1.19 tuple/ns, which match the result in Figure 11. 

## Figure 12
Figure 12 contains following (3 + 3 + 3 + 1) kernels:
+ Sparse vector/matrix/tensor addition on real numbers
+ Sparse vector/matrix/tensor element-wise multiplication on real numbers
+ Sparse vector/matrix/tensor element-wise multiplication on complex numbers
+ A useful merge opration might be used in shortest path algorithms

The experiments for Figure 12 are conducted similarly to Figure 11. The difference for this time is that, unfortunately, we have different input files for different kernels. 

```bash
SIMD_WIDTH=16 # repeat and let SIMD_WITDH to take all 5 values {4, 8, 16, 32, 64}
SCALAR_REPEAT=5 # the number of repeated executions for scalar (baseline) to take
SIMD_REPEAT=5 # the number of repeated executions for simd (proposed) to take

cd /root/basicProblemExplore/

## (6 kernels here) {vector/matrix/tensor} addition and element-wise multiplication on real numbers
python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin Add Mul file ComplexJoin/vector_real.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}
python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin Add Mul file ComplexJoin/matrix_real.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}
python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin Add Mul file ComplexJoin/tensor_real.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}

## (3 kernels here) {vector/matrix/tensor} element-wise multiplication on complex numbers
python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin MulComplex file ComplexJoin/vector_complex.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}
python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin MulComplex file ComplexJoin/matrix_complex.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}
python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin MulComplex file ComplexJoin/tensor_complex.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}

## (1 kernel here) A merge operation in shortest path
python gem5ArmRunner.py ${SIMD_WIDTH} ComplexJoin ShortestPath file ComplexJoin/vector_real.bin scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}
```
(There are 7 independent Gem5 simulation runs in above code snippet, you may need to scroll up the history to see all the results.)

Similar to the scenario of above SetOperation, you need to *SIMD_WIDTH* to other values {4,8,16,32,64} to collect the results for different CPU SIMD width settings, but you only need to collect the result fo scalar baseline once (it does not change with *SIMD_WIDTH*).

### Calculate the throughput
Now, we can compute the throughput using the execution time. In this expriment, both inputs has 10000 elements. So the throughput=((size(a)+size(b))/execution time)= ((10000+10000)/execution time). We can use the throughput numbers to draw Figure 12.

## Figure 14
Figure 14 contains only one kernel: sorting kernel. We consider 4 implementations:
+ std::sort: which is quicksort (scalar baseline 1)
+ std::stable_sort: which is merge sort (scalar baseline 2)
+ Bramas SIMD: which is a SIMD-based sort (SIMD baseline)
+ Proposed SIMD: a SIMD-based sort (Proposed solution)

We also consider 2 use settings:
+ Sorting 32bit key-only array
+ Sorting 32bit+32bit key-value pairs (will be labeled as "(kv)" suffix)

*Note on correctness check*: For 32bit+32bit key-value sorting, non-stable sort implementation (std::sort and Bramas SIMD) is expected to fail the check on their value part, but still pass the key part. Stable sort implementation (std::stable_sort and Proposed SIMD) will path both key-part and value-part. 

To obtain the results, run the binary JoinOp. For example, to test SIMD width 16, run following:
```bash
SIMD_WIDTH=16 # repeat and let SIMD_WITDH to take all 5 values {4, 8, 16, 32, 64}
SCALAR_REPEAT=5 # the number of repeated executions for scalar (baseline) to take
SIMD_REPEAT=5 # the number of repeated executions for simd (proposed) to take

cd /root/basicProblemExplore/
python gem5ArmRunner.py ${SIMD_WIDTH} Sort scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}
python gem5ArmRunner.py ${SIMD_WIDTH} SortKV scalar ${SCALAR_REPEAT} simd ${SIMD_REPEAT}
```
Similar to the scenario of above SetOperation, you need to *SIMD_WIDTH* to other values {4,8,16,32,64} to collect the results for different CPU SIMD width settings (for both the SIMD baseline "Bramas SIMD" and our "Proposed SIMD"), but you only need to collect the result for the two scalar baselines once (i.e. the std::sort and std::stable_sort, as they do not change with *SIMD_WIDTH*).

### Calculate the throughput
Now, we can compute the throughput using execution time. In this experiment, the has 10000 elements. So the throughput=(size(a))/execution time)= (10000/execution time). We can use the throughput numbers to draw Figure 14.

## Figure 15
Figure 15 contains one kernel: SpGEMM (sparse matrix multiply sparse matrix, i.e. $C_{ij} = \sum_k A_{ik} B_{kj}$). We include a collection of scalar baselines. Due to the much longer execution time for each simulation, we wrote a script to run multiple simulations and parse their result.

The considered implementation includes:
+ Open source library Eigen (scalar baseline 1)
+ Heap-based SpGEMM (scalar baseline 2)
+ Hash-based SpGEMM (scalar baseline 3)
+ Dense vector-based SpGEMM (scalar baseline 4) 
+ Merge-based SpGEMM (scalar baseline 5)
+ Merge-based SpGEMM with SIMD acceleration (proposed solution)

We will test four pairs of input matrices with different numbers of non-zeros per row. You only need to run the following:
```bash
SIMD_WIDTH=4 # in principle, you need to repeat and let SIMD_WITDH take all 5 values {4, 8, 16, 32, 64} ... but to save your time, you can only do this for 4 here to collect the scalar kernel performance (since SIMD_WIDTH has no impact on them). Latter I will provide another code snippet to run only SIMD kernels, and you need to iterate SIMD_WITDH over {4, 8, 16, 32, 64} for there (not here).
SCALAR_REPEAT=5 # the number of repeated executions for scalar kernels
SIMD_REPEAT=5 # the number of repeated executions for simd (proposed)

cd /root/SpMMBenchmarks
python ./Workflow/middleExpand.py execGem5Parallel all vecLen=${SIMD_WIDTH} scalar=${SCALAR_REPEAT} simd=${SIMD_REPEAT}
python ./Workflow/middleExpand.py report all
```

The result will be collected into a CSV file /root/SpMMBenchmarks/csvResults/middleExpand-csvReport.csv. The row is the title of each column. The first column is kernel name ("kernelName"). The 2rd, 3th, 4th, and the 5th column ad the execution time of those kernels for different input matrix pairs ($A$ and $B$), and the numbers in the first row of each column (30,60,90 and 120) are the number of non-zeros per row in ($A$ and $B$). (More detailed execution for every single run, please see /root/SpMMBenchmarks/workload/(name of the kernel)/(name of the kernel)-(dataset id)--workload-report.json)

Similar to the scenario of above SetOperation, you need to *SIMD_WIDTH* to other values {4,8,16,32,64} to collect the results for different CPU SIMD width settings ("Proposed SIMD"), but you only need to collect the result for the two scalar baselines once (i.e. Hash, Heap, Dense, Merge, Eigen, as they do not change with *SIMD_WIDTH*). To avoid running the scalar baseline for different SIMD widths (the scalar kernels that takes a lot of time to simulate), you can tell the script not to run them and only run the SIMD kernel like the following (Note: this step will overwrite the results in CSV file middleExpand-csvReport.csv instead of appending new resuts to the old ones. So remember to backup them before you rerun the simulation :). ):

```bash
SIMD_WIDTH=4 # repeat and let SIMD_WITDH to take all 5 values {4, 8, 16, 32, 64}
SCALAR_REPEAT=5 # the number of repeated executions for scalar kernels
SIMD_REPEAT=5 # the number of repeated executions for simd (proposed)

cd /root/SpMMBenchmarks
python ./Workflow/middleExpand.py execGem5Parallel ProposedSIMD vecLen=${SIMD_WIDTH} scalar=${SCALAR_REPEAT} simd=${SIMD_REPEAT}
python ./Workflow/middleExpand.py report ProposedSIMD
```

### Calculate the throughput
Because SpGEMM is a time-consuming kernel and Gem5 simulate CPU is about 3~4 magnitude slower than a real CPU, we make the number of rows of matrix A relatively small to keep the simulation time reasonably acceptable. It is important to know that SpGEMM processes matrix multiplication in a row-by-row manner and each row is of A is relatively independent. So the execution time of larger matrix A (with more rows) can be estimated accurately by sampling a number of rows. The throughput is therefore calculated as following: Throughput= (number_of_rows_for_A * nnz_per_row_for_A * nnz_per_row_for_B / execution time). In our expriment, the number_of_rows_for_A is 20, The nnz_per_row_for_A/B is shown in the first row (i.e. 30, 60, 90, 120 respectively). You can easily check those matrix parameters in the json files:
```
/root/SpMMBenchmarks/workload/middleExpand/dense/middleExpand-1-workload-report.json
/root/SpMMBenchmarks/workload/middleExpand/dense/middleExpand-2-workload-report.json
/root/SpMMBenchmarks/workload/middleExpand/dense/middleExpand-3-workload-report.json
/root/SpMMBenchmarks/workload/middleExpand/dense/middleExpand-4-workload-report.json
```

### A note if your simulation crush.
I encountered a subtle bug that happens under very specific conditions. It is not caused by any part of my code, but somewhere from Gem5 and/or Glibc.  When all the following conditions are satisfied, your program may crush:
1. In your program, you dynamically allocate an array whose size is about 40K~80K bytes and NOT a multiple of (SIMD_WIDTH * 4byte). The array is automatically initialized (i.e. allocated using c++ containers like ```std::vector<int>``` instead of malloc). 
2. You compile it to Arm assembly and run it on Gem5 and set SIMD_WIDTH >= 16.
3. The program crush only when you free the memory (not when you allocate it or read/write it). In particular, it seems that bookkeeping formation padded before the first byte of allocated is overwritten by someone. 
4. There is nothing to do with my modification/my new instructions. This bug still occurs even for unmodified Gem5/GCC on the simplest scalar program. 

This bug is very subtle. For example, if the array is OK to contain 10048 integers but not 10047 or 10049 integers. If your array is far smaller than 40K bytes, or far greater than 80K bytes, the program also works fine. I think it might be related to the ``memset'' in Glibc, which is a highly optimized assembly code sequence and use many tricks to handle the head/tail of the allocated array that is not aligned to SIMD_WIDTH*4byte. I guess that they just assumed that SIMD_WIDTH<=16 so didn’t handle the larger width that we will simulate on Gem5.

For many kernels, I deliberately allocate arrays by padding unused zeros to them to be a multiple of 64 elements and do all allocation at once in the beginning and free them together in the end. This works for most cases. For SpGEMM kernels, however, it seems that two scalar kernels will trigger this bug. But since scalar kernels don’t care about SIMD width, we can just run them in SIMD_WIDTH = 4 or 8 to avoid this problem.

