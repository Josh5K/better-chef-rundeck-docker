FROM alpine:3.4

RUN addgroup -g 3000 -S passenger && adduser -u 1000 -S passenger  -G passenger 

RUN apk --no-cache add \
    libgcrypt \
    libstdc++ \
    libxml2 \
    libxslt \
    nodejs \
    pcre \
    procps \
    ruby-bigdecimal \
    ruby-io-console \
    ruby-irb \
    curl  \
    ruby \
    ruby-bundler \
    ruby-json \
    ruby-rake \
  && echo "gem: --no-document" > /etc/gemrc

RUN apk --no-cache add --virtual .passenger-deps \
    gcc \
    g++ \
    make \
    linux-headers \
    curl-dev \
    pcre-dev \
    ruby-dev

RUN apk --no-cache --virtual .build-deps add  \
    build-base \
    libffi-dev \
    ruby-dev \
    tar
ENV PASSENGER_VERSION=5.0.30
RUN gem install -v $PASSENGER_VERSION passenger \
  && echo "#undef LIBC_HAS_BACKTRACE_FUNC" > /usr/include/execinfo.h \
  && passenger-config install-standalone-runtime --auto \
  && passenger-config build-native-support

WORKDIR /app

ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_IGNORE_MESSAGES=1 \
    BUNDLE_GITHUB__HTTPS=1 \
    NOKOGIRI_USE_SYSTEM_LIBRARIES=1 \
    BUNDLE_PATH=/app/vendor/bundle \
    BUNDLE_BIN=/app/bin \
    BUNDLE_GEMFILE=/app/Gemfile \
    BUNDLE_WITHOUT=development:benchmark:test

RUN curl -sfLo better-chef-rundeck.tar.gz "https://github.com/atheiman/better-chef-rundeck/archive/v0.6.0.tar.gz"
RUN tar -xzf better-chef-rundeck.tar.gz --strip-components=1
RUN rm better-chef-rundeck.tar.gz
RUN sed -i "/^gem 'passenger'/d" Gemfile
RUN bundle update
RUN chmod 777 ./
USER passenger

CMD ["passenger", "start", "--environment", "production"]
