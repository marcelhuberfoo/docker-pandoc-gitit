FROM marcelhuberfoo/cabal-build

MAINTAINER Marcel Huber <marcelhuberfoo@gmail.com>

USER root
RUN echo -e '[infinality-bundle]\nSigLevel=Never\nServer = http://bohoomil.com/repo/$arch\n[infinality-bundle-fonts]\nSigLevel=Never\nServer = http://bohoomil.com/repo/fonts' >> /etc/pacman.conf && \
    pacman -Syy --noconfirm reflector git && \
    reflector --country Switzerland --country Germany --latest 5 --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -Syyu --noconfirm

USER $UNAME
RUN bash -l -c 'cabal update && git clone https://github.com/jgm/gitit && cd gitit && \
    cabal install --jobs --allow-newer --reorder-goals --enable-split-objs --enable-executable-stripping . pandoc pandoc-citeproc'
RUN bash -l -c 'rm -rf gitit/'

USER root
RUN pacman -S --noconfirm fontconfig-infinality-ultimate freetype2-infinality-ultimate cairo-infinality-ultimate ibfonts-meta-base && printf "y\\ny\\n" | pacman -Scc
RUN pacman -S --noconfirm git python-pip texlive-latexextra inkscape gtk2 graphviz mime-types jre8-openjdk-headless && \
    printf "y\\ny\\n" | pacman -Scc
RUN pip install pandocfilters

ADD https://gist.githubusercontent.com/marcelhuberfoo/42cd8b3dd971ed833d3b/raw/6418ed5e973868fef7e5cefe47982944e70b79ee/pandoc-svg.py /pandoc-svg.py
RUN chmod 0755 /pandoc-svg.py
COPY plantuml /usr/local/bin/plantuml
RUN mkdir -p /opt/plantuml && curl -L -o /opt/plantuml/plantuml.jar http://sourceforge.net/projects/plantuml/files/plantuml.jar/download && chmod +x /usr/local/bin/plantuml

ADD entrypoint.sh /entrypoint.sh
RUN rm -f /tmp/* || true
EXPOSE 5001
#CMD ["gitit", "-f", "/data/gitit.conf"]
CMD ["pandoc", "--help"]

