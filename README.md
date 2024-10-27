# Artifact Evaluation for Exo 2

To avoid confusion, we refer to Exo 2 simply as Exo in this documentation.

---

## Availability

[Exo](https://github.com/exo-lang/exo) and [ExoBLAS](https://github.com/exo-lang/ExoBLAS), our BLAS library implementation, are both publicly available on GitHub and are submodules of this artifact evaluation repository.
The Zenodo archive can be found [here](https://zenodo.org/records/13997026), which contains a source tarball of this repository.


---

## Functional

First, install Exo (Python>=3.9 is required):
```
pip install exo-lang
```

Then, run `functional.py`:
```
exocc functional.py
```
If you encounter a `ModuleNotFoundError: No module named 'attrs'` error, please upgrade your attrs module by running `pip install --upgrade attrs`.

Running `exocc` on `functional.py` will generate the C code in the `functional/functional.c` file.
It will also print out the intermediate steps of the example to demonstrate the functionalities of Cursors.

This example covers the key concepts presented in the paper:
- Finding Cursors with pattern-matching
- Cursor navigation
- Applying scheduling primitives using cursors
- Cursor forwarding after code transformations
- Defining a new scheduling operation

You can find examples from the paper as well as more detailed documentation within the source code of [functional.py](./functional.py).

For more comprehensive documentation on Exo's other language features, please refer to the [docs](https://github.com/exo-lang/exo/tree/main/docs) and [examples](https://github.com/exo-lang/exo/tree/main/examples).

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

### Halide library

This section reproduces Figure 10.

#### Generate blur and unsharp kernels with Exo

1. Generate `blur.c` using Exo:
   ```bash
   cd ~/exo2-artifact/exo/apps/x86/halide/blur
   exocc blur.py
   ```
   This will generate `blur/blur.c`.

2. Generate `unsharp.c` using Exo:
   ```bash
   cd ~/exo2-artifact/exo/apps/x86/halide/unsharp
   exocc unsharp.py
   ```

#### Run performance benchmark against Halide (Optional)

1. Install Halide on your local machine:
   - Download the appropriate Halide release 16.0.0 from the [Halide Github](https://github.com/halide/Halide/releases/tag/v16.0.0) and untar it.
   - Set the environment variable `Halide_DIR` to the path of the release:
     ```bash
     export Halide_DIR=/path/to/release
     # Example: export Halide_DIR=/home/ubuntu/Halide-16.0.0-x86-64-linux
     ```
     Note: You should not need to build Halide from source to run the benchmarks.

2. Compare the performance of the Exo-generated kernels against the Halide-generated kernels:
   - Navigate to `~/exo2-artifact/Halide/app/<kernel>/`.
   - Create a folder called `exo_<kernel>`.
   - Copy the Exo-generated `<kernel>.c` and `<kernel>.h` files (from the previous section) into the `exo_<kernel>` folder.
   - Create a folder called `build/` and navigate into it.
   - Run `cmake ..` and `make` from within the `build/` folder.
   - Run `Halide/app/<kernel>/benchmark.sh` to run the suite of benchmarks between the Exo and Halide generated kernels.

3. (Optional) Generate graphs:
   - Save the benchmark outputs into `.txt` files.
   - Run `Halide/apps/halide_graph.py` on those output files to generate graphs.

   For example, for blur:
   ```bash
   cd exo2-artifact/Halide/apps/blur
   mkdir build && cd build
   cmake .. && make
   cd ..
   ./benchmark.sh > results.txt
   cat results.txt | python3 ../halide_graph.py blur
   ```
   Follow the same steps for unsharp.

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


#### Run Performance Benchmark Against Existing Libraries (Optional, Highly Time-Consuming)

To run the benchmark for Exo-generated kernels:
```bash
ctest --test-dir ./build/avx512 -R exo_
```

To run the benchmark for the reference BLAS library:
```bash
ctest --test-dir ./build/avx512 -R cblas_
```

Running these benchmarks will create a `benchmark_results` directory containing json files with the performance results.


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

### AVX512 matmul benchmark

Figure 4(b).

TODO: Write



---


### Gemmini matmul benchmark

This section provides data for Figure 4(a) and part of Figure 4(c).

Unfortunately, we are not able to provide reproduction scripts for our Gemmini timings because they require access to expensive FPGA AWS instances (Firesim). However, Exo can still generate Gemmini C code, and reviewers can take a look at the generated C code and the scheduling transformation needed to reach the reported number in the paper.

To view the original and scheduled matmul for Gemmini:

1. Navigate to the `asplos25` directory:
   ```bash
   cd ~/exo2-artifact/exo/tests/asplos25
   ```

2. Run the `test_gemmini_matmul_new.py` script with pytest:
   ```bash
   python3 -m pytest test_gemmini_matmul_new.py -s
   ```
   The script will print the original and scheduled matmul for Gemmini.

---

### Count the number of rewrites (Optional, time-consuming)

This section reproduces the data for Figure 8(b).

1. Navigate to the Exo directory:
   ```bash
   cd ~/exo2-artifact/exo
   ```

2. Checkout the `count_rewrites` branch:
   ```bash
   git checkout count_rewrites
   ```

3. Rebuild and install Exo:
   ```bash
   python3 -m pip uninstall exo-lang
   python3 -m build .
   python3 -m pip install dist/*.whl
   ```

4. Rerun the Halide and BLAS builds as shown in the previous sections.
   - For Halide, follow the steps in the "Halide library" section.
   - For BLAS, follow the steps in the "BLAS library" section.

5. The number of primitive rewrites will be printed to the standard output (stdout) during the build process.

