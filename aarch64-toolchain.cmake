# aarch64-toolchain.cmake

# Set the target system name
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Set the cross compilers
set(bin_path /usr/bin)
set(CMAKE_C_COMPILER ${bin_path}/aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER ${bin_path}/aarch64-linux-gnu-g++)
set(BUILD_WITH_CXX_11 OFF)

# Set the target architecture
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(JSONCPP_WITH_TESTS OFF)