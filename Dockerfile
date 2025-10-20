FROM alpine:3.22.2 AS builder

RUN apk update && apk upgrade && apk add --no-cache alpine-sdk linux-headers git zlib-dev openssl-dev gperf cmake

WORKDIR /usr/src

# Клонируем репозиторий
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git

# Переходим в папку с исходным кодом
WORKDIR /usr/src/telegram-bot-api

# Создаем директорию для сборки и компилируем
# Используем флаг CMAKE_INSTALL_PREFIX, как в официальной инструкции,
# чтобы скомпилированный файл оказался в /usr/src/telegram-bot-api/bin
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. && \
    cmake --build . --target install

FROM alpine:3.22.2

RUN apk add --no-cache openssl libstdc++

WORKDIR /opt/telegram-bot-api

COPY --from=builder /usr/src/telegram-bot-api/bin/telegram-bot-api .

EXPOSE 8081

CMD ["./telegram-bot-api", "--local"]