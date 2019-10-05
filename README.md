# gps_docker
Docker image containing gps driver and scripts

# Requirement
- docker

# Install and build
```
git clone https://github.com/amslabtech/gps_docker.git
cd gps_docker
./build.sh
```

# How to use
```
./run_docker.sh

# if you want to set parameters
./run_docker.sh port:=/dev/ttyUSB1 baud:=38400 use_rmc:=False
```
