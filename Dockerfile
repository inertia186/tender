FROM inertia/meeseeker:latest

# default steemd node
ENV STEEMD_NODE_URL "https://api.steemit.com"

# used by steemsmartcontracts
ENV NODE_URL "${STEEMD_NODE_URL}"

# used by meeseeeker
ENV MEESEEKER_NODE_URL "${STEEMD_NODE_URL}"

# used by tender
ENV ENGINE_NODE_URL "http://127.0.0.1:5000"

ENV SSC_ROOT /steemsmartcontracts
ENV APP_ROOT /tender
WORKDIR /tender

# For mongodb, used by Steem Smart Contract blockchain storage.
RUN \
  curl -sL https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - && \
  echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.2 main" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list

RUN \
  apt-get update && \
  apt-get install -y \
    systemd \
    mongodb \
    monit \
    curl \
    jq

# Setup a Steem Smart Contracts node.
RUN \
  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  apt-get install -y \
    git \
    nodejs && \
  npm install pm2 -g && \
  cd / && \
  git clone https://github.com/harpagon210/steemsmartcontracts.git && \
  cd $SSC_ROOT && \
  git checkout mongodb2 && \
  tmpfile=$(mktemp) && \
  cat config.json | jq ".streamNodes[0] |= \"${NODE_URL}\"" > ${tmpfile} && \
  cat ${tmpfile} > config.json && \
  npm install

RUN \
  /bin/bash -c " \
    source /usr/local/rvm/scripts/rvm && \
    rvm install ruby-2.4.2 && \
    gem install bundler && \
    bundle config --global silence_root_warning 1 \
  "

# copy in everything from repo
COPY app app
COPY config config
COPY db db
COPY lib lib
COPY public public
COPY config.ru .
COPY Gemfile .
COPY Gemfile.lock .
COPY package.json .
COPY Rakefile .
COPY LICENSE .
COPY README.md .

RUN \
  /bin/bash -c " \
    source /usr/local/rvm/scripts/rvm && \
    cd $APP_ROOT && \
      rvm use ruby-2.4.2 && \
      rvm rvmrc warning ignore /tender/Gemfile \
      gem install bundler && \
      bundle config --global silence_root_warning 1 && \
      bundle lock --add-platform x86-mingw32 x86-mswin32 x64-mingw32 java && \
      bundle update --bundler && \
      bundle install --without development test && \
      RAILS_ENV=production bundle exec rake db:migrate && \
      RAILS_ENV=production bundle exec rake db:seed && \
      RAILS_ENV=production bundle exec rake assets:precompile \
  "

RUN \
  /bin/bash -c " \
    source /usr/local/rvm/scripts/rvm && \
    cd /meeseeker && \
      rvm use ruby-2.4.2 && \
      bundle lock --add-platform x86-mingw32 x86-mswin32 x64-mingw32 java && \
      bundle install \
  "

COPY bin bin
RUN chmod +x /tender/bin/*.sh
RUN $APP_ROOT/bin/docker-configure-monit.sh

ENTRYPOINT \
  /bin/bash -c " \
    source /usr/local/rvm/scripts/rvm && \
    $APP_ROOT/bin/docker-entry-point.sh \
  "
  
# redis
EXPOSE 6379
# explorer node
EXPOSE 3000
# ssc node
EXPOSE 5000
