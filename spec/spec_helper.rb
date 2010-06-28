# encoding: utf-8

puts "Statsample-SEM specs: Running on Ruby Version: #{RUBY_VERSION}"

require "rubygems"
require 'spec'
require 'spec/autorun'
require 'statsample'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib') 
require 'statsample/sem'
