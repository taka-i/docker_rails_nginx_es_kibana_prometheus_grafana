FROM ruby:2.6.3
RUN apt-get update -qq && apt-get install -y build-essential default-libmysqlclient-dev nodejs

ENV READY_RAILS_DIR=/ready_rails
WORKDIR $READY_RAILS_DIR
COPY Gemfile .
COPY application.rb .
COPY database.yml .
COPY puma.rb .

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
RUN touch Gemfile.lock
RUN bundle install

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 744 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
