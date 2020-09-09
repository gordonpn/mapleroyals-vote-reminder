FROM ruby:2.7-alpine
RUN adduser \
    --disabled-password \
    --home /home/appuser \
    --shell /bin/bash \
    --system \
    --uid 1000 \
    appuser
RUN bundle config --global frozen 1
RUN apk update && apk add --no-cache \
    build-base \
    tzdata
RUN cp /usr/share/zoneinfo/America/Montreal /etc/localtime
RUN echo "America/Montreal" >/etc/timezone
WORKDIR /home/appuser
USER appuser
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
CMD ["ruby", "./main.rb"]
