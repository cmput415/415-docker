FROM ubuntu:22.04 AS build

RUN apt-get update && \
  apt-get install -y build-essential \
  cmake \
  ninja-build \
  git \
  python3 python3-pip \
  libtool \
  clang lld \
  curl

WORKDIR /home

#TODO: Remove this
RUN git config --global http.sslVerify false
RUN git clone https://github.com/llvm/llvm-project.git && \
  cd llvm-project && \
  git checkout llvmorg-18.1.8

ENV LLVM_HOME=/home/llvm
WORKDIR /home/llvm-project
RUN mkdir build && cd build && \
  cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir;clang;clang-tools-extra" \
    -DLLVM_TARGETS_TO_BUILD="Native" \
    -DCMAKE_BUILD_TYPE=MinSizeRel   \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -DLLVM_USE_LINKER=lld \
    -DCMAKE_INSTALL_PREFIX=$LLVM_HOME \
  && ninja install -j $(nproc)

ENV ANTLR_INS=/home/antlr4/inst
WORKDIR /home
RUN git clone https://github.com/antlr/antlr4.git

WORKDIR /home/antlr4
RUN git checkout 4.13.0 && \
  mkdir build && cd build && \
  cmake ../runtime/Cpp/ \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX=$ANTLR_INS
RUN make -C build/ install -j $(nproc)

##------------------------------------------------------
FROM ubuntu:22.04 AS install
RUN apt-get update && \
  apt-get install -y \
  openjdk-17-jre \
  cmake ninja-build \
  build-essential\
  pkg-config \
  libncurses5-dev\
  uuid-dev \
  zlib1g-dev \
  python3 \
  git \
  gdb clang \
  curl

ENV MLIR_INS=/opt/llvm
ENV ANTLR_INS=/opt/antlr4/inst
ENV ANTLR_BIN=$ANTLR_INS/bin
ENV MLIR_DIR=/opt/llvm/lib/cmake/mlir

COPY --from=build /home/antlr4/inst $ANTLR_INS
COPY --from=build /home/llvm $MLIR_INS

ENV PATH=/usr/local/bin:$PATH

RUN mkdir -p $ANTLR_BIN
RUN curl -k https://www.antlr.org/download/antlr-4.13.0-complete.jar -o $ANTLR_BIN/antlr-4.13.0-complete.jar

ENV ANTLR_JAR=$ANTLR_BIN/antlr-4.13.0-complete.jar
ENV CLASSPATH="$ANTLR_JAR:$CLASSPATH"
RUN echo "alias antlr4='java -Xmx500M org.antlr.v4.Tool'" >> /root/.bashrc
RUN echo "alias grun='java org.antlr.v4.gui.TestRig'" >> /root/.bashrc

RUN apt-get install python3-pip -y
RUN pip install colorama
RUN git clone https://github.com/cmput415/Dragon-Runner.git && cd Dragon-Runner; pip install .

WORKDIR /workspace

CMD ["/bin/bash"]FROM ubuntu:22.04 AS build

RUN apt-get update && \
  apt-get install -y build-essential \
  cmake \
  ninja-build \
  git \
  python3 python3-pip \
  libtool \
  clang lld \
  curl

WORKDIR /home

#TODO: Remove this
RUN git config --global http.sslVerify false
RUN git clone https://github.com/llvm/llvm-project.git && \
  cd llvm-project && \
  git checkout llvmorg-18.1.8

ENV LLVM_HOME=/home/llvm
WORKDIR /home/llvm-project
RUN mkdir build && cd build && \
  cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir;clang;clang-tools-extra" \
    -DLLVM_TARGETS_TO_BUILD="Native" \
    -DCMAKE_BUILD_TYPE=MinSizeRel   \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -DLLVM_USE_LINKER=lld \
    -DCMAKE_INSTALL_PREFIX=$LLVM_HOME \
  && ninja install -j $(nproc)

ENV ANTLR_INS=/home/antlr4/inst
WORKDIR /home
RUN git clone https://github.com/antlr/antlr4.git

WORKDIR /home/antlr4
RUN git checkout 4.13.0 && \
  mkdir build && cd build && \
  cmake ../runtime/Cpp/ \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX=$ANTLR_INS
RUN make -C build/ install -j $(nproc)

##------------------------------------------------------
FROM ubuntu:22.04 AS install
RUN apt-get update && \
  apt-get install -y \
  openjdk-17-jre \
  cmake ninja-build \
  build-essential\
  pkg-config \
  libncurses5-dev\
  uuid-dev \
  zlib1g-dev \
  python3 \
  git \
  gdb clang \
  curl

ENV MLIR_INS=/opt/llvm
ENV ANTLR_INS=/opt/antlr4/inst
ENV ANTLR_BIN=$ANTLR_INS/bin
ENV MLIR_DIR=/opt/llvm/lib/cmake/mlir

COPY --from=build /home/antlr4/inst $ANTLR_INS
COPY --from=build /home/llvm $MLIR_INS

ENV PATH=/usr/local/bin:$PATH

RUN mkdir -p $ANTLR_BIN
RUN curl -k https://www.antlr.org/download/antlr-4.13.0-complete.jar -o $ANTLR_BIN/antlr-4.13.0-complete.jar

ENV ANTLR_JAR=$ANTLR_BIN/antlr-4.13.0-complete.jar
ENV CLASSPATH="$ANTLR_JAR:$CLASSPATH"
RUN echo "alias antlr4='java -Xmx500M org.antlr.v4.Tool'" >> /root/.bashrc
RUN echo "alias grun='java org.antlr.v4.gui.TestRig'" >> /root/.bashrc

RUN apt-get install python3-pip -y
RUN pip install colorama
RUN git clone https://github.com/cmput415/Dragon-Runner.git && cd Dragon-Runner; pip install .

WORKDIR /workspace

CMD ["/bin/bash"]
