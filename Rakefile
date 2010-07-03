# -*- ruby -*-
$:.unshift(File.dirname(__FILE__)+"/lib")
require 'rubygems'
require 'hoe'
require 'statsample/sem'
Hoe.plugin :git


Hoe.spec 'statsample-sem' do
  self.version=Statsample::SEM::VERSION
  self.rubyforge_name = 'ruby-statsample'
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
  self.extra_deps << ["statsample","~>0.13.1"] << ["rserve-client", "~>0.2.0"] << ['dirty-memoize']
end

# vim: syntax=ruby
