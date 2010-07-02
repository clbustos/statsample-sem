require 'rserve'
require 'statsample'
require 'statsample/sem/model'
require 'statsample/sem/openmxengine'
require 'statsample/sem/semjfoxengine'

module Statsample
  class SEM
    VERSION='0.1.0'
    attr_accessor :name
    attr_accessor :engine
    def initialize(opts=Hash.new,&block)
      default_opts={:name=>"SEM Analysis", :type=>"RAM"}
      @opts=default_opts.merge(opts)
      @name=@opts.delete :name
      @type=@opts.delete :type
      @paths=Array.new
      @covariance_based=false
      @cases=nil
      if block
        block.arity<1 ? instance_eval(&block) : block.call(self)
      end
    end
  end
end