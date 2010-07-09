require 'rserve'
require 'forwardable'
require 'statsample'
require 'statsample/rserve_extension'
require 'statsample/sem/model'
require 'statsample/sem/engine'
require 'statsample/sem/openmxengine'
require 'statsample/sem/semjfoxengine'

module Statsample
  class SEM
    extend Forwardable
    VERSION='0.1.0'
    attr_accessor :name
    attr_accessor :engine
    attr_reader :model
    attr_reader :engine_obj
    def_delegators :@model, :path, :data_from_matrix, :data_from_dataset, :manifests, :manifests=, :latents, :latents=, :data_variables, :data_variables=, :make_null
    def_delegators :@engine_obj, :summary, :chi_square, :df
    def initialize(opts=Hash.new, &block)
      default_opts={:name=>"SEM Analysis", :engine=>:sem}
      @opts=default_opts.merge(opts)
      @engine_obj=nil
      @engine = @opts.delete :engine
      @model=Statsample::SEM::Model.new(:name=>@name)
      if block
        block.arity<1 ? instance_eval(&block) : block.call(self)
      end
    end
    
    def name=(v)
        @opts[:name]=v
    end
    def name
      @opts[:name]
    end
    def compute
      @engine_obj=case @engine
      when :openmx
        OpenMxEngine.new(@model, @opts)
      when :sem
        SemJFoxEngine.new(@model, @opts)
      end
      @engine_obj.compute
      @engine_obj
    end
    def engine_obj
      @engine_obj||=compute
    end
    def r_summary
      engine_obj.r_summary
    end
  end
end
