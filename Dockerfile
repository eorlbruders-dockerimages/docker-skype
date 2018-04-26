FROM debian:jessie

# Install everything we need
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	--no-install-recommends

RUN curl -sSL https://repo.skype.com/data/SKYPE-GPG-KEY | apt-key add -
RUN echo "deb [arch=amd64] https://repo.skype.com/deb stable main" > /etc/apt/sources.list.d/skype.list

RUN apt-get update && apt-get -y install \
	skypeforlinux \
	--no-install-recommends

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes pulseaudio-utils pavucontrol
RUN rm -rf /var/lib/apt/lists/*

# Make a user (As everything tends to break when I change stuff here, I think it's kinda necessary to do it this way...)
ENV HOME /home/skype
RUN useradd --create-home --home-dir $HOME skype \
	&& chown -R skype:skype $HOME \
	&& usermod -a -G audio,video skype

RUN exportUID=1000 GID=1000
RUN mkdir -p "/home/skype"
RUN echo "skype:x:${UID}:${GID}:skype User,,,:/home/skype:/bin/bash" >> /etc/passwd
RUN echo "skype:x:${UID}:" >> /etc/group
RUN mkdir -p /etc/sudoers.d
RUN echo "skype ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/skype
RUN chmod 0440 /etc/sudoers.d/skype
RUN chown ${UID}:${GID} -R /home/skype
RUN gpasswd -a skype audio

# Copy config and entrypoint
COPY run-skype-and-wait-for-exit /usr/local/bin
COPY pulse-client.conf /etc/pulse/client.conf

# Set working environment
WORKDIR $HOME
USER skype

# Start Skype
ENTRYPOINT ["run-skype-and-wait-for-exit"]
