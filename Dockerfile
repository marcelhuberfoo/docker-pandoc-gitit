FROM marcelhuberfoo/cabal-build

MAINTAINER Marcel Huber <marcelhuberfoo@gmail.com>

USER root

RUN echo -e '[infinality-bundle]\nServer = http://bohoomil.com/repo/$arch\n[infinality-bundle-fonts]\nServer = http://bohoomil.com/repo/fonts' >> /etc/pacman.conf
RUN pacman-key --recv-keys 962DDE58 && pacman-key --lsign-key 962DDE58
RUN pacman -Syy --noconfirm fontconfig-infinality-ultimate freetype2-infinality-ultimate cairo-infinality-ultimate ibfonts-meta-base
RUN pacman -Syy --noconfirm git python-pip texlive-latexextra inkscape gtk2 graphviz && \
    printf "y\\ny\\n" | pacman -Scc
RUN pip install pandocfilters

ADD entrypoint.sh /entrypoint.sh
ADD https://gist.githubusercontent.com/marcelhuberfoo/42cd8b3dd971ed833d3b/raw/6418ed5e973868fef7e5cefe47982944e70b79ee/pandoc-svg.py /pandoc-svg.py
RUN chmod 0755 /pandoc-svg.py

RUN gosu $UNAME bash -c 'cabal update && \
    cabal install gitit pandoc-citeproc'

EXPOSE 5001
#CMD ["gitit", "-f", "/data/gitit.conf"]
CMD ["pandoc", "--help"]

