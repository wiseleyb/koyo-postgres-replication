FROM ruby:3.2.2-slim

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    git \
    build-essential \
    gnupg2 \
    less \
    libpq-dev \
    postgresql-client \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
  
RUN gem update --system && gem install bundler && gem install rails

WORKDIR /usr/src/app

COPY . .

RUN bundle install

CMD ["irb"] 
