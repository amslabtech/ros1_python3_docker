FROM ros:melodic-ros-base

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install --no-install-recommends -y\
                       wget \
                       ros-melodic-tf* \
                       libopencv-dev \
                       python-catkin-pkg \
                       python-catkin-tools \
                       python3-catkin-pkg-modules \
                       python3-rospkg-modules \
                       python3-opencv \
                       python3-pip \
    && rm -rf /var/lib/apt/lists/*

# ROS setting
WORKDIR /root

# create workspace and build cv_bridge for python3
RUN mkdir catkin_ws \
    && cd catkin_ws \
    && catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so \
    && catkin config --install \
    && mkdir src \
    && cd /root/catkin_ws/src \
    && git clone -b melodic https://github.com/ros-perception/vision_opencv.git \
    && cd /root/catkin_ws \
    && source /opt/ros/melodic/setup.bash \
    && catkin build cv_bridge \
    && source install/setup.bash --extend

RUN echo source /root/catkin_ws/devel/setup.bash >> .bashrc

ENV ROS_PACKAGE_PATH=/root/catkin_ws:$ROS_PACKAGE_PATH

ENV ROS_WORKSPACE=/root/catkin_ws

COPY ./ros_entrypoint.sh /

CMD ["/ros_entrypoint.sh"]

# install cuda and cudnn
# cite from https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/ubuntu18.04/9.2/base/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
        gnupg2 curl ca-certificates && \
        curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub | apt-key add - && \
        echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
        echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
        apt-get purge --autoremove -y curl && \
        rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 9.0.176

ENV CUDA_PKG_VERSION 9-0=$CUDA_VERSION-1

ENV CUDNN_VERSION 7.6.4.38
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

ENV NCCL_VERSION 2.4.8

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-libraries-$CUDA_PKG_VERSION \
        # cuda-nvtx-$CUDA_PKG_VERSION \
        cuda-cublas-9-0=$CUDA_VERSION.4-1 \
        libnccl2=$NCCL_VERSION-1+cuda9.0 \
        libcudnn7=$CUDNN_VERSION-1+cuda9.0 &&\
    apt-mark hold libnccl2 && \
    apt-mark hold libcudnn7 && \
    ln -s cuda-9.0 /usr/local/cuda && \
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
ENV NVIDIA_REQUIRE_CUDA "cuda>=9.0 "

RUN pip3 install setuptools
