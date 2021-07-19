# FROM binfalse/jekyll
FROM debian:testing
MAINTAINER Full Bright <full3right@gmail.com>


# doing all in once to get rid of the useless stuff
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    gcc \
    g++ \
    make \
    libc-dev \
    ruby \
    ruby-dev \
    ruby-all-dev \
    ruby-execjs \
    ruby-pygments.rb \
    libmagickwand-dev \
    locales
RUN gem install jekyll jekyll-paginate jekyll-paginate-v2 jekyll-sitemap jekyll-minifier jekyll-seo-tag bundler jekyll-feed jekyll-redirect-from jekyll-watch i18n jekyll-katex \
 && gem install rexml jekyll-admin jekyll-responsive-image \
 && gem install sassc -- --disable-march-tune-native
#  && apt-get purge -y -q --autoremove \
#     gcc \
#     g++ \
#     make \
#     libc-dev \
#     ruby-dev \
RUN apt-get clean \
 && rm -r /var/lib/apt/lists/* /var/cache/*

RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


# RUN apt-get update && apt-get install ruby2.7-dev -y
COPY Gemfile .
# RUN gem install rmagick -v '4.2.2' --source 'https://rubygems.org/'
# RUN gem install rexml -v 3.2.4
# RUN gem install i18n -v 1.8.9
# RUN gem install jekyll-admin
# RUN gem install jekyll-responsive-image
RUN bundle install


VOLUME ["/jekyll"]
WORKDIR /jekyll

ENTRYPOINT ["/usr/local/bin/jekyll"]
CMD ["build", "--incremental", "--watch"]
