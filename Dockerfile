FROM marcelhuberfoo/cabal-build

MAINTAINER Marcel Huber <marcelhuberfoo@gmail.com>

USER root

RUN echo -e '[infinality-bundle]\nServer = http://bohoomil.com/repo/$arch\n[infinality-bundle-fonts]\nServer = http://bohoomil.com/repo/fonts' >> /etc/pacman.conf
RUN pacman-key --recv-keys 962DDE58 && pacman-key --lsign-key 962DDE58
RUN pacman -Syy --noconfirm fontconfig-infinality-ultimate freetype2-infinality-ultimate cairo-infinality-ultimate ibfonts-meta-base
RUN pacman -Syy --noconfirm git texlive-core gtk2 graphviz && \
    printf "y\\ny\\n" | pacman -Scc

ADD entrypoint.sh /entrypoint.sh

RUN gosu $UNAME bash -c 'cabal update && \
    cabal install gitit'

EXPOSE 5001
#CMD ["gitit", "-f", "/data/gitit.conf"]
CMD ["pandoc", "--help"]

