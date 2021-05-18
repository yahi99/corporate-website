FROM binfalse/jekyll
COPY Gemfile .
RUN bundle install
RUN gem install rexml -v 3.2.4
RUN gem install i18n -v 1.8.9