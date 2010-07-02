# -*- ruby -*-

require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__)+"/lib")
require 'statsample/sem'
Hoe.spec 'statsample-sem' do
self.version=Statsample::SEM::VERSION
  self.rubyforge_name = 'statsample'
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
  self.extra_deps << ["statsample","~>0.13.0"] << ["rserve-client", "~>0.2.0"]
end

# vim: syntax=ruby
