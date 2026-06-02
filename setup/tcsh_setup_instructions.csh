## Setup for tcsh shell
# 1. Setup Env
  cd llama_cpp_dir/
  setenv LLAMA_HOME $PWD
  mkdir -p "$LLAMA_HOME"/{bin,src,models,logs,tmp}

# 2. Download and install micromamba and other requirements
  curl -L -o "$LLAMA_HOME/bin/micromamba" https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-64
  setenv MAMBA_ROOT_PREFIX "$LLAMA_HOME/mamba-root"
  "$LLAMA_HOME/bin/micromamba" create -y -p "$LLAMA_HOME/env" -c conda-forge python=3.12 git cmake ninja make pkg-config gcc_linux-64 gxx_linux-64 openblas libopenblas wget curl

# 3. Download llama.cpp
  mkdir -p "$LLAMA_HOME/src"
  $LLAMA_HOME/bin/micromamba run -p "$LLAMA_HOME/env" git clone https://github.com/ggml-org/llama.cpp.git "$LLAMA_HOME/src/llama.cpp"


# 4. Building llama.cpp
  cd "$LLAMA_HOME/src/llama.cpp"
  $LLAMA_HOME/bin/micromamba run -p "$LLAMA_HOME/env" env CC="$LLAMA_HOME/env/bin/x86_64-conda-linux-gnu-gcc" CXX="$LLAMA_HOME/env/bin/x86_64-conda-linux-gnu-g++" PKG_CONFIG_PATH="$LLAMA_HOME/env/lib/pkgconfig" LD_LIBRARY_PATH="$LLAMA_HOME/env/lib" cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS
  $LLAMA_HOME/bin/micromamba run -p "$LLAMA_HOME/env" cmake --build build -j`nproc`
  cd ../../

# 5. Download an LLM model
  wget -O "$LLAMA_HOME/models/tinyllama-q4.gguf" "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"


# 6 Run llama cli
  $LLAMA_HOME/bin/micromamba run -p "$LLAMA_HOME/env"  "$LLAMA_HOME/src/llama.cpp/build/bin/llama-cli" -m "$LLAMA_HOME/models/tinyllama-q4.gguf" -p "Explain what CPU-only inference means in two sentences." -n 64 -t `nproc`


# 7. Run llama.cpp server - Go to 127.0.0.1:8080/health and then http://127.0.0.1:8080/
  $LLAMA_HOME/bin/micromamba run -p "$LLAMA_HOME/env" "$LLAMA_HOME/src/llama.cpp/build/bin/llama-server" -m "$LLAMA_HOME/models/tinyllama-q4.gguf" --host 0.0.0.0 --port 8080 -t `nproc` -c 2048 -ngl 0

  OR 

  nohup $LLAMA_HOME/bin/micromamba run -p "$LLAMA_HOME/env" $LLAMA_HOME/src/llama.cpp/build/bin/llama-server -m $LLAMA_HOME/models/tinyllama-q4.gguf --host 0.0.0.0 --port 8080 -t `nproc` -c 2048 -b 256 -ngl 0 >&! $LLAMA_HOME/logs/llama-server.log &
