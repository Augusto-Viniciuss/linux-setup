# shellcheck shell=bash
# Source ROS 2 only when the user has installed it separately.
# The linux-setup installer deliberately does not add ROS apt sources or packages.
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${VERSION_ID:-}" in
    22.04) _linux_setup_ros_distro=humble ;;
    24.04) _linux_setup_ros_distro=jazzy ;;
    *) _linux_setup_ros_distro="${ROS_DISTRO:-}" ;;
  esac

  if [ -n "$_linux_setup_ros_distro" ]; then
    if [ -n "${ZSH_VERSION:-}" ]; then
      _linux_setup_ros_setup="/opt/ros/$_linux_setup_ros_distro/setup.zsh"
    else
      _linux_setup_ros_setup="/opt/ros/$_linux_setup_ros_distro/setup.bash"
    fi
    if [ -r "$_linux_setup_ros_setup" ]; then
      # This location is selected from the detected ROS distribution.
      # shellcheck disable=SC1090
      . "$_linux_setup_ros_setup"
    fi
  fi
  unset _linux_setup_ros_distro _linux_setup_ros_setup
fi
