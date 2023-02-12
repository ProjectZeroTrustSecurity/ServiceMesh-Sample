FROM ruby:alpine

RUN apk add --update \
  && rm -rf /var/cache/apk/*

WORKDIR /app
COPY Gemfile* /app/

RUN gem install webrick

WORKDIR /app
COPY divide.rb /app

EXPOSE 8080
CMD ["ruby", "./divide.rb"]
