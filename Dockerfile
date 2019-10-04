FROM ubuntu:18.04

LABEL description="Builder image for meeting-countdown."
LABEL maintainer="tuomas.jaakola@iki.fi"

RUN apt-get update && apt-get install -y curl \
  build-essential \
  git \
  mingw-w64 \
  pkg-config

# Download and extract development libraries under /usr/local

# SDL
RUN curl -SL https://www.libsdl.org/release/SDL2-devel-2.0.10-mingw.tar.gz \
  | tar -xzC /tmp \
  && cp -R /tmp/SDL2-2.0.10/i686-w64-mingw32/* /usr/local/ \
  && rm -rf /tmp/SDL2-2*

# SDL_ttf
RUN curl -SL https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-devel-2.0.15-mingw.tar.gz \
  | tar -xzC /tmp \
  && cp -R /tmp/SDL2_ttf-2.0.15/i686-w64-mingw32/* /usr/local/ \
  && rm -rf /tmp/SDL2_ttf*

# Download sources, compile and install libraries under /usr/i686-w64-mingw32/lib

# zlib
RUN curl -SL http://zlib.net/zlib-1.2.11.tar.gz \
  | tar -xzC /usr/local/src/ \
  && cd /usr/local/src/zlib* \
  && sed -e s/"PREFIX ="/"PREFIX = i686-w64-mingw32-"/ -i win32/Makefile.gcc \
  && make -f win32/Makefile.gcc \
  && BINARY_PATH=/usr/i686-w64-mingw32/bin \
  INCLUDE_PATH=/usr/i686-w64-mingw32/include \
  LIBRARY_PATH=/usr/i686-w64-mingw32/lib \
  make -f win32/Makefile.gcc install \
  && rm -rf /usr/local/src/zlib*

# libpng
RUN curl -SL http://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz \
  | tar -xzC /usr/local/src/ \
  && cd /usr/local/src/libpng* \
  && ./configure \
  --host=i686-w64-mingw32 \
  --prefix=/usr/i686-w64-mingw32 \
  CPPFLAGS="-I/usr/i686-w64-mingw32/include" \
  LDFLAGS="-L/usr/i686-w64-mingw32/lib" \
  && make \
  && make install \
  && rm -rf /usr/local/src/libpng*

# freetype
RUN curl -SL http://downloads.sourceforge.net/project/freetype/freetype2/2.8/freetype-2.8.tar.gz \
  | tar -xzC /usr/local/src/ \
  && cd /usr/local/src/freetype* \
  && ./configure \
  --host=i686-w64-mingw32 \
  --prefix=/usr/i686-w64-mingw32 \
  --enable-static \
  CPPFLAGS="-I/usr/i686-w64-mingw32/include" \
  LDFLAGS="-L/usr/i686-w64-mingw32/lib" \
  PKG_CONFIG_LIBDIR=/usr/i686-w64-mingw32/lib/pkgconfig \
  && make \
  && make install \
  && rm -rf /usr/local/src/freetype*

# Remove conflicting libc6-dev and clean
RUN apt-get purge -y libc6-dev \
  && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/*

VOLUME ["/code"]
WORKDIR /code

CMD ["make"]
