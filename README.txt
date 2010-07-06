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

=== OUTPUT 

    = SEM analysis
      Manifests: VAR1, VAR2, VAR3, VAR4, VAR5
      Latents  : G
      Chi-square: 7.384 (d.f=5)
      Parameter estimation
    +------+------+---------------+------------+------------+
    | From |  To  |     Label     |  estimate  |     de     |
    +------+------+---------------+------------+------------+
    | G    | G    | var G (Fixed) | 1.0        | --         |
    | G    | VAR1 | G to VAR1     | 0.39715249 | 0.01558258 |
    | G    | VAR2 | G to VAR2     | 0.50366170 | 0.01827672 |
    | G    | VAR3 | G to VAR3     | 0.57724183 | 0.02049979 |
    | G    | VAR4 | G to VAR4     | 0.70277431 | 0.02407548 |
    | G    | VAR5 | G to VAR5     | 0.79625084 | 0.02674307 |
    | VAR1 | VAR1 | var VAR1      | 0.04081422 | 0.00282540 |
    | VAR2 | VAR2 | var VAR2      | 0.03801998 | 0.00281854 |
    | VAR3 | VAR3 | var VAR3      | 0.04082727 | 0.00316526 |
    | VAR4 | VAR4 | var VAR4      | 0.03938699 | 0.00342167 |
    | VAR5 | VAR5 | var VAR5      | 0.03628702 | 0.00369160 |
    +------+------+---------------+------------+------------+
    
    = Null Model
      Manifests: VAR1, VAR2, VAR3, VAR4, VAR5
      Latents  : G
      Chi-square: 3725.060 (d.f=10)
      Parameter estimation
    +------+------+---------------+------------+------------+
    | From |  To  |     Label     |  estimate  |     de     |
    +------+------+---------------+------------+------------+
    | G    | G    | var G (Fixed) | 1.0        | --         |
    | VAR1 | VAR1 | var VAR1      | 0.19854430 | 0.01258228 |
    | VAR2 | VAR2 | var VAR2      | 0.29169500 | 0.01847955 |
    | VAR3 | VAR3 | var VAR3      | 0.37403540 | 0.02369243 |
    | VAR4 | VAR4 | var VAR4      | 0.53327880 | 0.03377395 |
    | VAR5 | VAR5 | var VAR5      | 0.67030230 | 0.04244876 |
    +------+------+---------------+------------+------------+


== REQUIREMENTS:

* statsample
* R with sem and/or OpenMx packages installed

== INSTALL:

* sudo gem install statsample-sem

== LICENSE:

GPL-2 
