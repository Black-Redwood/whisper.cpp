FROM ubuntu:22.04 AS build
WORKDIR /app

RUN apt-get update && \
  apt-get install -y build-essential \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY .. .
RUN make

FROM ubuntu:22.04 AS runtime
WORKDIR /app

RUN apt-get update && \
  apt-get install -y curl ffmpeg wget python3 \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY --from=build /app /app

RUN bash ./models/download-ggml-model.sh base

WORKDIR /usr/local/bin
RUN wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
RUN chmod 755 yt-dlp

WORKDIR /app/transcriptions

EXPOSE 3456

ENTRYPOINT [ "python3", "server.py" ]
