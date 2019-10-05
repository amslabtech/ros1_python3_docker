FROM ros:melodic-ros-base

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install --no-install-recommends -y\
                       ros-melodic-tf* \
                       libopencv-dev \
                       python-catkin-pkg \
                       python-catkin-tools \
                       python3-catkin-pkg-modules \
                       python3-rospkg-modules \
                       python3-opencv \
    && rm -rf /var/lib/apt/lists/*

# ROS setting
WORKDIR /root

RUN mkdir -p catkin_ws/src

RUN cd catkin_ws && source /opt/ros/melodic/setup.bash; catkin build

RUN cd /root && echo source /root/catkin_ws/devel/setup.bash >> .bashrc

ENV ROS_PACKAGE_PATH=/root/catkin_ws:$ROS_PACKAGE_PATH

ENV ROS_WORKSPACE=/root/catkin_ws

WORKDIR /root

# cv_bridge for python3
RUN catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so \
    && catkin config --install \
    && cd catkin_ws/src \
    && git clone -b melodic https://github.com/ros-perception/vision_opencv.git \
    && cd ../ \
    && catkin build cv_bridge

COPY ./ros_entrypoint.sh /

CMD ["/ros_entrypoint.sh"]

# install cuda and cudnn
# cite from https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/ubuntu18.04/9.2/base/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
        gnupg2 curl ca-certificates && \
        curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1710/x86_64/7fa2af80.pub | apt-key add - && \
        echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1710/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
        echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
        apt-get purge --autoremove -y curl && \
        rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 9.2.148

ENV CUDA_PKG_VERSION 9-2=$CUDA_VERSION-1

ENV CUDNN_VERSION 7.6.4.38
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

ENV NCCL_VERSION 2.4.8

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-libraries-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-1+cuda10.0 \
        libcudnn7=$CUDNN_VERSION-1+cuda9.2 &&\
    apt-mark hold libnccl2 && \
    apt-mark hold libcudnn7 && \
    ln -s cuda-9.2 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=9.2 "

