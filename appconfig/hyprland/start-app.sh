#!/usr/bin/env bash
set -euo pipefail

# NixGL adds its Mesa libraries to Hyprland's environment. System GUI apps
# such as Ubuntu's Kitty must use Ubuntu's matching EGL/GL libraries.
unset LD_LIBRARY_PATH __EGL_VENDOR_LIBRARY_FILENAMES LIBGL_DRIVERS_PATH GBM_BACKENDS_PATH

exec "$@"
