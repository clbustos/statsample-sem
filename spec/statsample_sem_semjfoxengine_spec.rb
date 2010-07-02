$:.unshift(File.dirname(__FILE__)+"/.")
require 'spec_helper'

describe Statsample::SEM::SemJFoxEngine do
  before(:all) do
    begin 
      @data_path=File.dirname(__FILE__)+"/fixtures/demo_open_mx.ds"
      @ds=Statsample.load(@data_path)
    rescue 
      @data_path=File.dirname(__FILE__)+"/fixtures/demo_open_mx.csv"
      @ds=Statsample::CSV.read(@data_path)
    end
    @cov_matrix=Statsample::Bivariate.covariance_matrix(@ds)
    @cases=@ds.cases
  end
  describe "using matrix based data" do 
    before(:each) do
      @model=Statsample::SEM::Model.new do |m|
        m.manifests @ds.fields
        m.latents %w{G}
        m.path :from=>m.latents, :to=>m.manifests
        m.path :from=>m.manifests
        m.path :from=>m.latents, :free=>false, :values=>1.0
        m.data_from_matrix(@cov_matrix,:cases=>@cases)
      end
      @engine=Statsample::SEM::SemJFoxEngine.new(@model)
    end
    it "should generate a valid r query" do
      @engine.r_query.size.should>=0
    end
    it "should compute and return well formed response" do
      lambda{@engine.compute}.should_not raise_error
      @engine.summary.should be_instance_of (Array)
    end
  end
  
  
end

