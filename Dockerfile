FROM debian:stretch-slim

# Enable contrib and non-free
COPY sources.list /etc/apt/sources.list

# Accept EULA for MS fonts
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections # Accept EULA for MS fonts

# Install suitable version of Python:
# Install browser and fonts
RUN apt-get update \
  &&  apt-get install -y software-properties-common x11vnc xvfb gnupg apt-transport-https \
  &&  apt-get install -y chromium dbus wget xfonts-base ttf-mscorefonts-installer fonts-arphic-bkai00mp \
      fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp fonts-arphic-gkai00mp fonts-arphic-ukai \
      fonts-farsiweb fonts-nafees fonts-sil-abyssinica fonts-sil-ezra fonts-sil-padauk \
      fonts-unfonts-extra fonts-unfonts-core fonts-indic fonts-thai-tlwg fonts-lklug-sinhala \
  &&  apt-get install -y python3-dev python3-gdbm curl git libffi-dev libssl-dev \
  &&  curl "https://bootstrap.pypa.io/get-pip.py" | python3 \
  &&  rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Install Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install google-chrome-stable dbus-x11 packagekit-gtk3-module libcanberra-gtk-module \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Install brozzler itself:
RUN export LC_ALL=C.UTF-8 && \
    pip3 install brozzler[dashboard]==1.1b11
#    pip3.5 install 'git+https://github.com/internetarchive/brozzler.git#[webconsole]'

# Add our starter scripts:
ADD xvfb-run-chromium-browser.sh /usr/bin
ADD run-chrome-headless.sh /usr/bin

# Add a non-root user to run things as:
RUN useradd headless --shell /bin/bash --create-home \
  && usermod -a -G sudo headless \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'headless:nopassword' | chpasswd

RUN mkdir /data && chown -R headless:headless /data

USER headless

#
EXPOSE 8000

#
CMD brozzler-worker --warcprox-auto

