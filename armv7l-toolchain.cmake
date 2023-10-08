# armv7l-toolchain.cmake

# Set the target system name
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armv7l)

# Set the cross compilers
set(bin_path /usr/bin)
set(CMAKE_C_COMPILER ${bin_path}/arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${bin_path}/arm-linux-gnueabihf-g++)

# The BUILD_WITH_CXX_11 option is kept as is (OFF) 
# but you can adjust if your application requires C++11 features
set(BUILD_WITH_CXX_11 OFF)

# Set the target architecture
set(CMAKE_SYSTEM_PROCESSOR gnueabihf)

# disable tests since we're cross compiling
set(JSONCPP_WITH_TESTS OFF)