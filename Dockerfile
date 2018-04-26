FROM debian:jessie

# Get dependencies required for Skypes installation
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	--no-install-recommends

# Install Skype
RUN curl -sSL https://repo.skype.com/data/SKYPE-GPG-KEY | apt-key add -
RUN echo "deb [arch=amd64] https://repo.skype.com/deb stable main" > /etc/apt/sources.list.d/skype.list

RUN apt-get update && apt-get -y install \
	skypeforlinux \
	--no-install-recommends

# Install Pulseaudio-Stuff
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
  pulseaudio-utils pavucontrol \
	--no-install-recommends

# Clean Up after Installation
RUN rm -rf /var/lib/apt/lists/*

# Configure Skype
COPY run-skype-and-wait-for-exit /usr/local/bin

# Configure pulseaudio
COPY pulse-client.conf /etc/pulse/client.conf

# Add Skype User
RUN export UNAME=skype UID=1000 GID=1000
RUN mkdir -p "/home/${UNAME}"
RUN echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd
RUN echo "${UNAME}:x:${UID}:" >> /etc/group
RUN mkdir -p /etc/sudoers.d
RUN echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME}
RUN chmod 0440 /etc/sudoers.d/${UNAME}
RUN chown ${UID}:${GID} -R /home/${UNAME}
RUN usermod -a -G audio,video skype

# Prepare Working Environment
WORKDIR $HOME
USER skype

# Start Skype
ENTRYPOINT ["run-skype-and-wait-for-exit"]
