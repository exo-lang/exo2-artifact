# Artifact evaluation for ASPLOS'25 Exo 2

To avoid confusion, we refer to Exo 2 simply as Exo in this documentation.

## Availability

[Exo](https://github.com/exo-lang/exo) and [ExoBLAS](https://github.com/exo-lang/ExoBLAS), our BLAS library implementation, are both publicaly available on github.
Source tarball on Zenodo can be found [here](...).

## Functional

The detailed documentation of Exo can be found in [docs](https://github.com/exo-lang/exo/tree/main/docs), as well as [examples](https://github.com/exo-lang/exo/tree/main/examples) that walk through Exo's usage.
For artifact evaluation, we made a [small example](functional.py) which demonstrates core functionalities of Cursor as discussed in the paper.

First, install Exo:
```
pip install exo-lang
```

And run `functional.py`:
```
exocc functional.py
```

You should be able to find examples from the paper as well as more detailed documentation in the source code.


## Reproducibility

Since we support many kernels on three different hardware targets and compared with existing libraries, we marked especially time-consuming evaluation as optional. It's up to reviewers if they wish to take on that journey or not.

In case you have a trouble installing dependencies (Halide, LLVM, Google benchmark, OpenBLAS, MKL) on your local machine, **we prepared a AWS server with all the dependency setup**. Private key should be found in the artifact evaluation website. If you cannot find it, contact Yuka Ikarashi at [yuka@csail.mit.edu](mailto:yuka@csail.mit.edu).

To reproduce main results of paper, clone this repo.
```
git clone git@github.com:exo-lang/exo2-artifact.git
git submodule update --init --recursive
```

### Build Halide library

Run whatever apps/Halide thing which shouldn't be that bad

#### Run performance benchmark against Halide (Optional)

First you need to install Halide (and LLVM as its dependency) on your local machine.
We will outline what worked for our AWS server (Ubuntu 18.08) but the installation process will be different depending on your hardware, OS, and existing environment.
The best place to find the Halide documentation is [README](https://github.com/halide/Halide) and the [build docs](https://github.com/halide/Halide/blob/main/doc/BuildingHalideWithCMake.md).



### Build BLAS library


#### Run performance benchmark against OpenBLAS and MKL (Optional, highly time-consuming)


### Build GEMMINI library
Unfortunately, we are not able to provide reproduction scripts for our GEMMINI timings because they require access to prototype hardware. However, Exo can still generate GEMMINI C code, and reviewers can take a look at the generated C code and the scheduling transformation needed to reach the reported number in the paper.


#### Count the number of rewrites (Optional)

Go to Exo, checkout `count_rewrites` branch and run Halide and BLAS build again.


