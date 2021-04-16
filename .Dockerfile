# ROSPlan docker image
ARG ROS_DISTRO
FROM ros:${ROS_DISTRO}

SHELL ["/bin/bash", "-c"]
WORKDIR /root/ws


# install dependencies (follows dependencies from README.md)
RUN apt-get update &&\
    apt-get install git flex bison freeglut3-dev libbdd-dev ros-${ROS_DISTRO}-tf2-bullet -y &&\
    if test $ROS_DISTRO = 'noetic'; then \
        apt-get install python3-osrf-pycommon python3-catkin-tools python3-rospkg -y; \
    else \
        apt-get install python-catkin-tools python-rospkg; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# Create WS
RUN source /opt/ros/${ROS_DISTRO}/setup.bash &&\
    mkdir -p src/rosplan &&\
    catkin build --no-status

# Copy source files. 
COPY . src/rosplan/

# Get ROSPlan from repo
#RUN git clone --recurse-submodules --shallow-submodules --depth 1 https://github.com/KCL-Planning/ROSPlan.git src/rosplan

# Get related repos. ROSPlan demos are moved to kclplanning/rosplan:demos
#RUN git clone --depth 1 https://github.com/clearpathrobotics/occupancy_grid_utils.git src/occupancy_grid_utils &&\
#    git clone --depth 1 https://github.com/KCL-Planning/rosplan_demos.git src/rosplan_demos


# Further dependencies
RUN source /root/ws/devel/setup.bash &&\
    apt-get update &&\
    rosdep update &&\
    rosdep install --from-paths src/rosplan --ignore-src -r -y &&\
    rm -rf /var/lib/apt/lists/*

# Build workspace
RUN catkin build --summarize --no-status

# Prepare workspace for runtime. Set the prompt to be colored
# RUN echo -e "source /opt/ros/$ROS_DISTRO/setup.bash\nsource devel/setup.bash" >> ~/.bashrc &&\
#    sed -i s/^#force_color_prompt/force_color_prompt/g ~/.bashrc