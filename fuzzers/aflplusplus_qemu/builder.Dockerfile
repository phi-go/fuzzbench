# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG parent_image=gcr.io/fuzzbench/base-builder
FROM $parent_image

# Install wget to download afl_driver.cpp. Install libstdc++ to use llvm_mode.
RUN apt-get update && \
    apt-get install wget libstdc++-5-dev libtool-bin automake -y && \
    apt-get install flex bison libglib2.0-dev libpixman-1-dev -y

# Download and compile afl++ (v2.62d).
# Build without Python support as we don't need it.
# Set AFL_NO_X86 to skip flaky tests.
RUN git clone https://github.com/AFLplusplus/AFLplusplus.git /afl && \
    cd /afl && git checkout b126a5d5a8d90dcc10ccb890b379c3dfdc5cf8d4 && \
    unset CFLAGS && unset CXXFLAGS && \
    AFL_NO_X86=1 CC=clang PYTHON_INCLUDE=/ make && \
    cd qemu_mode && ./build_qemu_support.sh && cd .. && \
    make -C examples/aflpp_driver && \
    cp examples/aflpp_driver/libAFLQemuDriver.a /libAFLDriver.a && \
    cp examples/aflpp_driver/aflpp_qemu_driver_hook.so /
