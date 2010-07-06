$:.unshift(File.dirname(__FILE__)+"/../lib/")
require 'statsample'
require 'statsample/sem'
require 'matrix'


matrix=Matrix[[0.1985443,0.1999953,0.2311884,0.2783865,0.3155943],
[0.1999953,0.2916950,0.2924566,0.3515298,0.4019234],
[0.2311884,0.2924566,0.3740354,0.4061291,0.4573587],
[0.2783865,0.3515298,0.4061291,0.5332788,0.5610769],
[0.3155943,0.4019234,0.4573587,0.5610769,0.6703023]]


cases=500
sem1=Statsample::SEM.new(:name=>"SEM analysis") do |m|
    m.data_from_matrix(matrix,:cases=>cases)
    m.manifests m.data_variables
    m.latents %w{G}
    m.path :from=>m.latents, :to=>m.manifests
    m.path :from=>m.manifests
    m.path :from=>m.latents, :free=>false, :values=>1.0
    
end
sem1.compute
puts sem1.summary

sem2=sem1.dup
sem2.make_null

sem2.name="Null Model"

sem2.compute

puts sem2.summary

