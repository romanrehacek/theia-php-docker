FROM node:8-jessie-slim

ENV TZ=Europe/Bratislava
ENV UID=10000
ENV GID=1002

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update && apt-get -y --no-install-recommends install sudo curl xz-utils wget git python build-essential \
    && apt install -y --no-install-recommends ca-certificates apt-transport-https \
    && wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - \
    && echo "deb https://packages.sury.org/php/ jessie main" | tee /etc/apt/sources.list.d/php.list \
    && apt update \
    && apt install -y --no-install-recommends php7.2 \
    && apt install -y --no-install-recommends php7.2-cli php7.2-curl php7.2-json php7.2-mbstring \
    && curl -s -o composer-setup.php https://getcomposer.org/installer \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --gid $GID theia \
    && adduser --disabled-password --gecos '' --uid $UID --gid $GID theia \
    && adduser theia sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && chmod g+rw /home \
    && mkdir -p /home/project \
    && chown -R theia:theia /home/theia \
    && chown -R theia:theia /home/project

USER theia

WORKDIR /home/theia
ADD package.json ./package.json

RUN yarn --cache-folder ./ycache \
    && rm -rf ./ycache \
    && NODE_OPTIONS="--max_old_space_size=4096" yarn theia build

EXPOSE 3000
ENV SHELL /bin/bash

ENTRYPOINT [ "yarn", "theia", "start", "/home/project", "--hostname=0.0.0.0" ]

