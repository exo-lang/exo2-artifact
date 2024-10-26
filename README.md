# Artifact Evaluation for Exo 2

To avoid confusion, we refer to Exo 2 simply as Exo in this documentation.

---

## Availability

[Exo](https://github.com/exo-lang/exo) and [ExoBLAS](https://github.com/exo-lang/ExoBLAS), our BLAS library implementation, are both publicly available on GitHub and are submodules of this artifact evaluation repository.
The Zenodo archive can be found [here](https://zenodo.org/records/13997026), which contains a source tarball of this repository.


---

## Functional

For artifact evaluation, we made a [small example](functional.py) which demonstrates core functionalities of Cursor as discussed in the paper.

First, install Exo:
```
pip install exo-lang
```

And run `functional.py`:
```
exocc functional.py
```
In case of `ModuleNotFoundError: No module named 'attrs'` please upgrade your attrs module by `pip install --upgrade attrs`.

You should be able to find examples from the paper as well as more detailed documentation in the source code.

The detailed documentation of Exo can be found in [docs](https://github.com/exo-lang/exo/tree/main/docs), as well as [examples](https://github.com/exo-lang/exo/tree/main/examples) that walk through Exo's usage.

---

## Reproducibility

Since we support many kernels on three different hardware targets and have compared them with three existing libraries, we have marked especially time-consuming evaluations as optional.
It is up to the reviewers if they wish to embark on that journey or not.

In case you have a trouble installing dependencies (Halide, Google benchmark, cmake>=3.23, OpenBLAS, MKL, BLIS) on your local machine, **we prepared a AWS server with all the dependency setup**. Private key should be found in the artifact evaluation website. If you cannot find it, please contact [Yuka Ikarashi](mailto:yuka@csail.mit.edu) and [Kevin Qian](9kqian@gmail.com).
We have verified all the reproducibility steps on Ubuntu 22.04.5 LTS running on the AWS server (m7i.xlarge, Xeon Platinum 8488C).

To reproduce main results of paper, clone this repo.
```
git clone git@github.com:exo-lang/exo2-artifact.git
git submodule update --init --recursive
```

---

### Build Halide library

Figure 10

Run whatever apps/Halide thing which shouldn't be that bad

#### Run performance benchmark against Halide (Optional)

First, you will need to install Halide on your local machine. Download the appropriate Halide release 16.0.0 from the [Halide Github](https://github.com/halide/Halide/releases/tag/v16.0.0) and untar it. Then, set the environment variable `Halide_DIR=<path/to/release>`. You should not need to build Halide from source to run the benchmarks.
```
export Halide_DIR=/home/ubuntu/Halide-16.0.0-x86-64-linux
```

Now, to compare the performance of the Exo-generated kernels against the Halide-generated kernels. Navigate to `Halide/app/<kernel>/`. Create a folder called `exo_<kernel>`, and copy over the exo-generated `<kernel>.c` and `<kernel>.h` files (see previous section) into that folder. Create a folder called `build/` and run `cmake ..` and `make` from within the `build/` folder. Then, run `Halide/app/<kernel>/benchmark.sh` to run our suite of benchmarks between the Exo and Halide generated kernels.
For example, for blur run the following:
```
cd exo2-artifact/Halide/apps/blur
mkdir build && cd build
cmake .. && make
cd ..
./benchmark.sh > results.txt
cat results.txt | python3 ../format_benchmark_output.py blur
```
Exactly the same for unsharp.

If you want to generate graphs, cat those outputs into `.txt` files and then run `Halide/apps/format_benchmark_output.py`  on those output files



---


### BLAS Library

This section reproduces Figures 7, 8(a), 11, 12, 13, 14, and 15.
All the experiments in this section are performed in the [ExoBLAS](./ExoBLAS) submodule. Please navigate into it.

#### Installing Requirements

- Install Python requirements by running `python3 -m pip install -r requirements.txt`.
- Ensure you have `cmake` version 3.23 or higher installed.
- Install Ninja (on Ubuntu, use `apt install ninja-build`).
- Install one or more of the following BLAS libraries:
  - OpenBLAS (on Ubuntu, use `apt install libopenblas-dev`).
  - MKL (follow [Intel's instructions](https://www.intel.com/content/www/us/en/developer/articles/guide/installing-free-libraries-and-python-apt-repo.html) to install MKL).
  - BLIS (on Ubuntu, use `apt install libblis-dev`).

  We installed intel-mkl-2018.2-046 as mentioned in the MKL documentation, 0.8.1-2 for libblis, and 0.3.20 for OpenBLAS. After installing MKL, remember to set the `MKLROOT` environment variable to allow Exo to discover the installed location: `export MKLROOT=/opt/intel/mkl`.
- Install Google Benchmark by following these steps:
```bash
$ git clone https://github.com/google/benchmark
$ cmake -S benchmark -B benchmark/build -DCMAKE_BUILD_TYPE=Release -DBENCHMARK_ENABLE_TESTING=NO
$ cmake --build benchmark/build
$ cmake --install benchmark/build --prefix ~/.local
```


#### Building the ExoBLAS Library

After installing the requirements, navigate to the `exo2-artifact/ExoBLAS` directory and run the following commands to build the library for the AVX-512 target:
```bash
cmake --preset avx512
cmake --build build/avx512/
```

If unspecified in the `cmake --preset` command, CMake will attempt to find an existing BLAS implementation to link against.
If you wish to control which existing library to compare the performance against, you can use the `-DBLA_VENDOR` option as follows:
```bash
$ cmake --preset avx512 -DBLA_VENDOR=OpenBLAS         # Use OpenBLAS as a reference
$ cmake --preset avx512 -DBLA_VENDOR=Intel10_64lp_seq # Use MKL as a reference
$ cmake --preset avx512 -DBLA_VENDOR=FLAME            # Use BLIS as a reference
```

The subsequent explanations assume that you have built ExoBLAS for AVX-512 instructions to reproduce the AVX-512 results presented in the paper. However, if you wish to reproduce the AVX2 results instead, simply replace all occurrences of `avx512` with `avx2` in the following instructions.


#### Counting Lines of Code

The following script counts the lines of code for the BLAS library, as reported in Figure 8 (a):
```bash
python3 analytics_tools/loc/count_loc.py
```

Please note that this script will print out more kernels than what was reported in the paper, as ExoBLAS supports a superset of kernels compared to those included in the paper.


#### Run performance benchmark against existing libraries (Optional, highly time-consuming)

Compile all the benchmark tests (Check if this is necessary or not!)
```
cmake --build build/avx2 --target _bench
```

To run the benchmark for Exo generated kernels:
```
ctest --test-dir ./build/avx512 -R exo_
```

To run the benchmark for the reference BLAS library:
```
ctest --test-dir ./build/avx512 -R cblas_
```

This will create a `benchmark_results` directory containing json files.


#### Plotting the Graphs (Optional)

To run the graph script, you'll need to install the Linux Libertine font:
```bash
sudo apt-get install fonts-linuxlibertine
fc-cache -f -v
rm ~/.cache/matplotlib/fontlist-*.json
```

Organize the `benchmark_results` directory:
```bash
./analytics_tools/graphing/organize.sh benchmark_results
```

Plot all the kernels using the following command:
```bash
python3 analytics_tools/graphing/graph.py all AVX512 benchmark_results
```

The graphs will be generated in the `analytics_tools/graphing/` directory.
After generating the graphs, you can copy them to your local machine using the `scp` command to review the output.



---

### Run AVX512 GEMM benchmark

Figure 4(b).

TODO: Write



---

### Build GEMMINI library

Figure 4(a) and part of 4(c).

Unfortunately, we are not able to provide reproduction scripts for our GEMMINI timings because they require access to prototype hardware. However, Exo can still generate GEMMINI C code, and reviewers can take a look at the generated C code and the scheduling transformation needed to reach the reported number in the paper.


---

### Count the number of rewrites (Optional)

Figure 8(b).

Go to Exo, checkout `count_rewrites` branch and run Halide and BLAS build again.
You'll need to rebuild Exo from scratch:
```
python3 -m pip uninstall exo-lang
python3 -m build .
python3 -m pip install dist/*.whl
```



