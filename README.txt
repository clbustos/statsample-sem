= statsample-sem

* http://ruby-statsample.rubyforge.org/

== DESCRIPTION:

Structural equation modeling (SEM) for statsample gem, usign ruby and R

== FEATURES/PROBLEMS:

* Abstract generation of models. You could use R packages sem or OpenMx only changing the configuration for engine
* Generates visual representations of output models using GraphViz (to implement)

== SYNOPSIS:

    require 'statsample'
    require 'statsample/sem'
    require 'matrix'    
    matrix=Matrix[[0.1985443,0.1999953,0.2311884,0.2783865,0.3155943],
    [0.1999953,0.2916950,0.2924566,0.3515298,0.4019234],
    [0.2311884,0.2924566,0.3740354,0.4061291,0.4573587],
    [0.2783865,0.3515298,0.4061291,0.5332788,0.5610769],
    [0.3155943,0.4019234,0.4573587,0.5610769,0.6703023]]
    
    cases=500
    sem1=Statsample::SEM.new do |m|
        m.data_from_matrix(matrix,:cases=>cases)
        m.variables=%w{x1 x2 x3 x4 x5} # Variables on matrix
        m.manifests %w{x1 x2 x3 x4 x5}
        m.latents %w{G}
        m.path :from=>m.latents, :to=>m.manifests
        m.path :from=>m.manifests
        m.path :from=>m.latents, :free=>false, :values=>1.0
    end
    sem1.compute
    puts sem1.chi_square
    
    sem2=sem1.dup
    sem2.make_null # Generate a null model
    sem2.compute
    puts sem2.chi_square
    puts sem2.df


== REQUIREMENTS:

* statsample
* R with sem and/or OpenMx packages installed

== INSTALL:

* sudo gem install statsample-sem

== LICENSE:

GPL-2 
