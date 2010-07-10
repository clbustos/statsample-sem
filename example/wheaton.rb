$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'statsample'
require 'statsample/sem'
matrix= Matrix[
[11.834,  6.947,    6.819,   4.783,  -3.839, -21.899],
[6.947,   9.364,    5.091,   5.028,  -3.889, -18.831], 
[6.819,   5.091,    12.532,  7.495,  -3.841, -21.748],
[4.783,   5.028,    7.495,   9.986,  -3.625, -18.775],
[-3.839,  -3.889,  -3.841,  -3.625,   9.610,  35.522],
[-21.899, -18.831, -21.748, -18.775, 35.522,  450.288]
]

matrix.extend Statsample::CovariateMatrix
matrix.fields=%w{Anomia67 Powerless67 Anomia71 Powerless71 Education SEI}

model=Statsample::SEM::Model.new(:name=>"Wheaton data") do |m|
  m.data_from_matrix(matrix, :cases=>932)
  m.latents=%w{Alienation67 Alienation71 SES}
  m.manifests=matrix.fields
  m.path :from=>"Alienation67", :to=>%w{Anomia67}, :free=>false, :values=>1.0
  m.path :from=>"Alienation67", :to=>%w{Powerless67 Alienation71}, :labels=>["lam1","beta"]
  m.path :from=>"Alienation71", :to=>%w{Anomia71}, :free=>false, :values=>1.0
  m.path :from=>"Alienation71", :to=>%w{Powerless71}, :labels=>["lam2"]
  m.path :from=>"SES", :to=>%w{Alienation67 Alienation71}, :labels=>%w{gam1 gam2}
  m.path :from=>"SES", :to=>%w{Education}, :free=>false, :values=>1.0
  m.path :from=>"SES", :to=>%w{SEI}, :labels=>["lam3"]
  m.path :from=>m.manifests, :arrows=>2, :labels=>%w{the11 the22 the33 the44 thd11 thd22}
  m.path :from=>m.latents, :arrows=>2, :labels=>%w{psi11 psi22 phi}
end
engine=Statsample::SEM::SemJFoxEngine.new(model, :name=>"Wheaton data")
engine.compute
puts engine.summary
model2=model.dup

model2.path :from=>"Anomia67", :to=>"Anomia71", :labels=>%w{the13}, :arrows=>2
engine2=Statsample::SEM::SemJFoxEngine.new(model2, :name=>"Wheaton data with the13")
engine2.compute
pp 1-Distribution::ChiSquare.cdf(engine2.chi_square, engine2.df.to_i)
puts engine2.summary
