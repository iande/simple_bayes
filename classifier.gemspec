# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'classifier/version'

Gem::Specification.new do |s|
  s.name         = "classifier"
  s.version      = Classifier::VERSION
  s.authors      = ["Lucas Carlson"]
  s.email        = "lucas@rufy.com"
  s.homepage     = "http://github.com/nragaz/classifier"
  s.summary      = "Bayesian and LSI classification in Ruby."
  s.description  = "Classifier is a general module to allow Bayesian and other types of classifications. Forked at nragaz/classifier from cardmagic/classifier."

  s.files        = `git ls-files app lib`.split("\n")
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
#  s.rubyforge_project = '[none]'

  s.add_dependency('ruby-stemmer', '>= 0.9.1')
  s.requirements << "A stemmer module to split word stems."
end
