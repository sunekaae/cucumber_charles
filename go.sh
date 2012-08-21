#!/bin/sh
bundle install --deployment
bundle exec rake tests
