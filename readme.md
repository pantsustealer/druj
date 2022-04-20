```shell
mkdir build
cd build
cmake ..
cmake --build . --target prepare -- -j 3
cmake --build . --target druj -- -j 3
```