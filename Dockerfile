FROM quay.io/fedora/ruby-33:20250909

# Install lib
USER 0
RUN dnf autoremove
RUN dnf install libyaml-devel jemalloc-devel -y

# Install deps
USER 1001
COPY --chown=1001:0 ./Gemfile* .
RUN gem install bundler && bundle install

# Copy code
COPY --chown=1001:0 . .

# Compile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets
RUN SECRET_KEY_BASE_DUMMY=1 rails assets:precompile

# Clean for prod
RUN bundle config set --local without 'development test' && bundle install && bundle clean --force

ENV PORT="8080"
ENV TARGET_PORT="8080"
ENV LD_PRELOAD="/usr/lib64/libjemalloc.so.2"
ENV RAILS_ENV="production"
ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["./bin/thrust", "./bin/rails", "server", "-b", "0.0.0.0"]
