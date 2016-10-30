FROM debian:jessie

WORKDIR /workdir

RUN apt-get update
RUN apt-get install -y curl

# see: https://wiki.debian.org/CrossToolchains#In_jessie_.28Debian_8.29
RUN echo "deb http://emdebian.org/tools/debian/ jessie main" > /etc/apt/sources.list.d/crosstools.list
RUN curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add -
RUN dpkg --add-architecture armhf

RUN apt-get update
RUN apt-get install -y bc build-essential crossbuild-essential-armhf curl git-core libncurses5-dev
RUN apt-get install -y module-init-tools

COPY build_kernel.sh /workdir/
COPY config-4.4.11-hypriotos /workdir/config-4.4.11
CMD [ "/workdir/build_kernel.sh" ]