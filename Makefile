.DEFAULT_GOAL := test

.PHONY: test
test:
	./bin/run ruby -e "Dir['test/**/*_test.rb'].each { |f| load f }"

.PHONY: deploy
deploy:
	./bin/run bundle --path vendor/bundle --without development test && \
	./bin/serverless deploy


