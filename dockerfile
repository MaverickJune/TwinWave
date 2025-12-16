# CUDA 12.4 + cuDNN (Ubuntu 22.04)
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# ------------------------------------------------------------
# 1. OS dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates build-essential \
    python3 python3-dev python3-venv python3-pip \
 && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 2. Python venv
# ------------------------------------------------------------
ENV VENV=/opt/venv
RUN python3 -m venv ${VENV}
ENV PATH="${VENV}/bin:${PATH}"

RUN pip install --upgrade pip setuptools wheel

# ------------------------------------------------------------
# 3. PyTorch 2.6.0 (CUDA 12.4)
# ------------------------------------------------------------
RUN pip install \
    --index-url https://download.pytorch.org/whl/cu124 \
    torch==2.6.0 torchvision torchaudio

# ------------------------------------------------------------
# 4. FlashInfer (torch2.6 / cu124 전용 wheel)
# ------------------------------------------------------------
RUN pip install flashinfer-python==0.2.3 \
    -i https://flashinfer.ai/whl/cu124/torch2.6/

# ------------------------------------------------------------
# 5. Runtime dependencies (pyproject.toml 기준)
# ------------------------------------------------------------
RUN pip install \
    "sglang[all]==0.4.6.post5" \
    scikit-learn \
    accelerate

# ------------------------------------------------------------
# 6. Workspace
# ------------------------------------------------------------
WORKDIR /workspace

# ------------------------------------------------------------
# 7. Default shell
# ------------------------------------------------------------
CMD ["bash"]
