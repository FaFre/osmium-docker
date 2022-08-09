FROM debian:stable-slim as osmium_builder
LABEL maintainer="github@fabi.online"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git ca-certificates make cmake g++ \
    libprotozero-dev libboost-program-options-dev libbz2-dev zlib1g-dev liblz4-dev libexpat1-dev \
    libproj-dev libgeos++-dev libgdal-dev \
    && rm -rf /var/lib/apt/lists/*

#RUN wget https://raw.githubusercontent.com/joto/gdalcpp/master/gdalcpp.hpp -o /usr/local/include/

RUN git clone --depth 1 --branch v2.18.0 https://github.com/osmcode/libosmium.git
WORKDIR /libosmium/build
RUN cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -INSTALL_GDALCPP=on -WITH_PROJ=on .. && make && make install

RUN git clone --depth 1 --branch v1.14.0 https://github.com/osmcode/osmium-tool.git /osmium-tool
WORKDIR /osmium-tool/build
RUN cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .. && make && make install

FROM scratch

COPY --from=osmium_builder /usr/local/bin/osmium /usr/local/bin/