FROM ubuntu:16.04

# Install suitable version of Python:
RUN apt-get update && \
    apt-get install -y python3-dev python3-gdbm curl git libffi-dev libssl-dev && \
    curl "https://bootstrap.pypa.io/get-pip.py" | python3

# Accept EULA for MS fonts
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections # Accept EULA for MS fonts

# Install browser and fonts
RUN apt-get install -y software-properties-common x11vnc xvfb && \
    add-apt-repository multiverse && \
    apt-get update && \
    apt-get install -y chromium-browser xfonts-base ttf-mscorefonts-installer fonts-arphic-bkai00mp \
      fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp fonts-arphic-gkai00mp fonts-arphic-ukai \
      fonts-farsiweb fonts-nafees fonts-sil-abyssinica fonts-sil-ezra fonts-sil-padauk \
      fonts-unfonts-extra fonts-unfonts-core fonts-indic fonts-thai-tlwg fonts-lklug-sinhala

# Install brozzler itself:
RUN export LC_ALL=C.UTF-8 && \
    pip3 install brozzler[dashboard]==1.1b11
#    pip3.5 install 'git+https://github.com/internetarchive/brozzler.git#[webconsole]'

RUN apt-get install -y dbus

ADD xvfb-run-chromium-browser.sh /usr/bin
#
EXPOSE 8000

#
CMD brozzler-worker

