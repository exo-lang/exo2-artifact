#!/bin/bash
set -e

# Make the result directory
mkdir blas_results
mkdir blas_results/avx512
mkdir blas_results/avx2

# ---------------------------------------------------------
# Reproduce all the AVX512 performance results and figures
# ---------------------------------------------------------

echo "Benchmarking OpenBLAS's performance on AVX512"
cmake -S ExoBLAS/ --preset avx512 -DBLA_VENDOR=OpenBLAS
cmake --build ExoBLAS/build/avx512/
taskset -c 2 ctest --test-dir ExoBLAS/build/avx512 -R cblas_

echo "Benchmarking MKL's performance on AVX512"
cmake -S ExoBLAS/ --preset avx512 -DBLA_VENDOR=Intel10_64lp_seq
cmake --build ExoBLAS/build/avx512/
taskset -c 2 ctest --test-dir ExoBLAS/build/avx512 -R cblas_

echo "Benchmarking BLIS's performance on AVX512"
cmake -S ExoBLAS/ --preset avx512 -DBLA_VENDOR=FLAME
cmake --build ExoBLAS/build/avx512/
taskset -c 2 ctest --test-dir ExoBLAS/build/avx512 -R cblas_

echo "Benchmarking ExoBLAS's performance on AVX512"
taskset -c 2 ctest --test-dir ExoBLAS/build/avx512 -R exo_

echo "Organizing benchmark results"
chmod +x ./ExoBLAS/analytics_tools/graphing/organize.sh
./ExoBLAS/analytics_tools/graphing/organize.sh ExoBLAS/benchmark_results

echo "Generating graphs"
python3 ExoBLAS/analytics_tools/graphing/graph.py all AVX512 ExoBLAS/benchmark_results/level1
python3 ExoBLAS/analytics_tools/graphing/graph.py all AVX512 ExoBLAS/benchmark_results/level2

echo "Copying generated graphs to the results directory"
cp -r ExoBLAS/analytics_tools/graphing/graphs/all/* blas_results/avx512

# ---------------------------------------------------------
# Reproduce all the AVX2 performance results and figures
# ---------------------------------------------------------

echo "Benchmarking OpenBLAS's performance on AVX2"
cmake -S ExoBLAS/ --preset avx2 -DBLA_VENDOR=OpenBLAS
cmake --build ExoBLAS/build/avx2/
taskset -c 2 ctest --test-dir ExoBLAS/build/avx2 -R cblas_

echo "Benchmarking MKL's performance on AVX2"
cmake -S ExoBLAS/ --preset avx2 -DBLA_VENDOR=Intel10_64lp_seq
cmake --build ExoBLAS/build/avx2/
taskset -c 2 ctest --test-dir ExoBLAS/build/avx2 -R cblas_

echo "Benchmarking BLIS's performance on AVX2"
cmake -S ExoBLAS/ --preset avx2 -DBLA_VENDOR=FLAME
cmake --build ExoBLAS/build/avx2/
taskset -c 2 ctest --test-dir ExoBLAS/build/avx2 -R cblas_

echo "Benchmarking ExoBLAS's performance on AVX2"
taskset -c 2 ctest --test-dir ExoBLAS/build/avx2 -R exo_

echo "Organizing benchmark results"
chmod +x ./ExoBLAS/analytics_tools/graphing/organize.sh
./ExoBLAS/analytics_tools/graphing/organize.sh ExoBLAS/benchmark_results

echo "Generating graphs"
python3 ExoBLAS/analytics_tools/graphing/graph.py all AVX2 ExoBLAS/benchmark_results/level1
python3 ExoBLAS/analytics_tools/graphing/graph.py all AVX2 ExoBLAS/benchmark_results/level2

echo "Copying generated graphs to the results directory"
cp -r ExoBLAS/analytics_tools/graphing/graphs/all/* blas_results/avx2

