.PHONY: test

test :
	./bin/run ruby -e "Dir['test/**/*_test.rb'].each { |f| load f }"
