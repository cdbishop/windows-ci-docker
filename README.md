# C++ Windows CI Dockerfile

Based on [native-desktop](https://github.com/microsoft/vs-dockerfiles/tree/master/native-desktop) example from Microsoft

## Software
Installs the following  

msi packages:
* Nodejs LTS
* Yarn
* VS Build tools
* Python
* Git

NPM packages
* Parcel

Python packages
* conan
* pystache
* scp
* paramiko
* requests
* colorama (using VCA Technology fork which adds FORCE_COLOR + NO_COLOR environment variables)
* junitparser
 
uses based image mcr.microsoft.com/windows:10.0.17763.1039 - for support on aws windows server ami's

## Building
To build this image from this directory, run:

```batch
docker build -t buildtools2017native:latest -m 2GB .
```

## Running
To map and build native sources from a clean source repository, run:

```batch
docker run -m 2G -v %CD%:C:\src buildtools2017native:latest --name Solution msbuild /m c:\src\Solution.sln
```

You can optionally pass specific configurations to build as well.

```batch
docker run -m 2G -v %CD%:C:\src buildtools2017native:latest --name Solution msbuild /m c:\src\Solution.sln /p:Configuration=Debug /p:Platform=x64
```

To build again run the container created in the previous step, e.g.
```batch
docker start -a Solution
```

You can omit the -a that attaches the container to view the output if desired.

## Issues

* If the repository is not clean and the mapped directory is not on the same drive or the same path as the host directory, native project builds will fail with a front-end compiler error.
* The compile flag /CI causes a compiler error when used in a container. In your project properties under C/C++ change Debug Information Format to C7 compatible when building in a container.
