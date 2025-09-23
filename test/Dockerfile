# Simple integration environment to validate initial-setup.sh on Ubuntu
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo git ca-certificates curl locales \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash dotbot \
    && echo "dotbot ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dotbot \
    && chmod 440 /etc/sudoers.d/dotbot

USER dotbot
WORKDIR /home/dotbot

COPY . /home/dotbot/dotfiles
WORKDIR /home/dotbot/dotfiles

# Run the installer end-to-end. This ensures apt installs succeed and
# dotfile symlinks, fonts, and plugin bootstraps complete without prompts.
RUN ./initial-setup.sh

# Sanity checks the container build should fail if expectations break.
RUN test -L /home/dotbot/.zshrc \
 && test -L /home/dotbot/.gitconfig \
 && test -d /home/dotbot/.config/tmux \
 && test -f /home/dotbot/.local/share/fonts/MesloLGLNerdFont-Regular.ttf

CMD ["/bin/bash"]
