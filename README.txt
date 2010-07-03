= statsample_sem

* http://github.com/clbustos/statsample-sem 

== DESCRIPTION:

Structural equation modeling (SEM), usign ruby and R

== FEATURES/PROBLEMS:

* Abstract generation of models. You could use R packages sem or OpenMx only changing the configuration for engine
* Generates visual representations of output models using GraphViz (to implement)

== SYNOPSIS:

  require 'statsample-sem'
  cov_matrix=Matrix[[0.56,0.54,0.3],[0.54,0.20,0.34],[0.3,0.34,0.9]]
  cov_matrix.extend Statsample::CovariateMatrix
  cov_matrix.fields=['x1','x2','x3']
  # Create a model
  model=Statsample::SEM::Model.new(:name=>"New Model") do |m|
    path :from=>'G', :to=>%w{x1 x2 x3} # Regression paths
    path :from=>%w{x1 x2 x3} # Free variances
    path :from=>'G', :arrows=>2, :free=>false, :values=>1.0 # Fixed variance of 
    data_from_matrix(cov_matrix,:type=>:covariance, :cases=>200)
  end
  # Feed the engine
  
  engine=Statsample::SEM::OpenMxEngine.new(model)
  engine.compute
  p engine.r_summary # ruby version of R summary

== REQUIREMENTS:

* statsample
* R with sem and/or OpenMx packages installed

== INSTALL:

* sudo gem install statsample-sem

== LICENSE:

GPL-2 
