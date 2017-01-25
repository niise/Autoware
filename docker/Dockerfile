FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu14.04
MAINTAINER Yuki Iida <aiueo.0409@gmail.com>

RUN apt-get update && apt-get install -y \
        software-properties-common \
        wget curl git cmake cmake-curses-gui

# Intall ROS
RUN wget http://packages.ros.org/ros.key -O - | apt-key add -
RUN echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list
RUN apt-get update && apt-get install -y \
        ros-indigo-desktop-full ros-indigo-nmea-msgs \
        ros-indigo-nmea-navsat-driver ros-indigo-sound-play \
        ros-indigo-jsk-visualization \
        ros-indigo-perception-pcl \
        ros-indigo-openni-launch \
        ros-indigo-turtlebot-simulator \
        libnlopt-dev freeglut3-dev qtbase5-dev \
        libqt5opengl5-dev libssh2-1-dev libarmadillo-dev libpcap-dev gksu
RUN rosdep init \
        && rosdep update \
        && echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc

# Develop
RUN apt-get install -y \
        libboost-all-dev \
        libflann-dev \
        libgsl0-dev \
        libgoogle-perftools-dev \
        libeigen3-dev \
        libglew-dev

# Intall some basic GUI and sound libs
RUN apt-get install -y \
                xz-utils file locales dbus-x11 pulseaudio dmz-cursor-theme \
                fonts-dejavu fonts-liberation hicolor-icon-theme \
                libcanberra-gtk3-0 libcanberra-gtk-module libcanberra-gtk3-module \
                libasound2 libgtk2.0-0 libdbus-glib-1-2 libxt6 libexif12 \
                libgl1-mesa-glx libgl1-mesa-dri \
        && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX

# Intall some basic GUI tools
RUN apt-get install -y \
        cmake-qt-gui \
        gnome-terminal

# GCC 4.9
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install -y gcc-4.9 g++-4.9 cpp-4.9 gcc-4.9-multilib g++-4.9-multilib
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 10
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 10

RUN add-apt-repository ppa:v-launchpad-jochen-sprickerhof-de/pcl
RUN apt-get update
RUN apt-get upgrade -y

# Install OpenCV
RUN apt-get update && apt-get -y install libopencv-dev build-essential cmake git libgtk2.0-dev pkg-config python-dev python-numpy libdc1394-22 libdc1394-22-dev libjpeg-dev libpng12-0 libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev libtbb-dev libqt4-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils unzip

RUN curl -L https://github.com/opencv/opencv/archive/2.4.13.2.tar.gz | tar xz && \
    cd opencv-2.4.13.2 && \
    mkdir build && \
    cd build/ && \
    cmake -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D CUDA_GENERATION=Auto -D WITH_CUBLAS=1 -D WITH_QT=ON -D WITH_OPENGL=ON -D WITH_VTK=ON .. && \
    make -j8 && \
    make install 
ENV PKG_CONFIG_PATH $PKG_CONFIG_PATH:/usr/local/lib/pkgconfig


# Install Caffe ssd
RUN apt-get install -y \
        cython \
        libatlas-base-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        liblapack-dev \
        liblapack3 \
        libleveldb-dev \
        liblmdb-dev \
        libopenblas-base \
        libopenblas-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-pip \
        python-skimage         

RUN pip install protobuf
RUN git clone https://github.com/weiliu89/caffe.git ssdcaffe && \
        cd ssdcaffe && \
        git checkout ssd && \
        cp Makefile.config.example Makefile.config && \
        echo "USE_CUDNN := 1" >> Makefile.config && \
        make -j8 && \
        make -j8 py && \
        make test -j8 && \
        make distribute

# Add basic user
ENV USERNAME autoware
ENV PULSE_SERVER /run/pulse/native
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        # Replace 1000 with your user/group id
        usermod  --uid 1000 $USERNAME && \
        groupmod --gid 1000 $USERNAME

# Setup .bashrc for ROS
RUN echo "source /opt/ros/indigo/setup.bash" >> /home/$USERNAME/.bashrc && \
        # python for caffe
        echo "export PYTHONPATH=~/ssdcaffe/python:$PYTHONPATH" >> ~/.bashrc \
        #Fix for qt and X server errors
        echo "export QT_X11_NO_MITSHM=1" >> /home/$USERNAME/.bashrc && \
        # cd to home on login
        echo "cd" >> /home/$USERNAME/.bashrc 

# Change user
USER autoware

# Install Autoware
RUN git clone https://github.com/CPFL/Autoware.git /home/$USERNAME/Autoware
RUN /bin/bash -c 'source /opt/ros/indigo/setup.bash; cd /home/$USERNAME/Autoware/ros/src;catkin_init_workspace; cd ../;LIBRARY_PATH=/usr/lib/OpenNI2/Drivers:$LIBRARY_PATH ./catkin_make_release'
RUN echo "source /home/$USERNAME/Autoware/ros/devel/setup.bash" >> /home/$USERNAME/.bashrc

# Change Terminal Color
RUN gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_background" --type bool false
RUN gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_colors" --type bool false
RUN gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#FFFFFF"

# Default CMD
CMD ["gnome-terminal"]
