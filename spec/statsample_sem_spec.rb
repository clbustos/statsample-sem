$:.unshift(File.dirname(__FILE__)+"/.")
require 'spec_helper'

describe Statsample::SEM do
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
    @sem=Statsample::SEM.new do |m|
      m.manifests @ds.fields
      m.latents %w{G}
      m.path :from=>m.latents, :to=>m.manifests
      m.path :from=>m.manifests
      m.path :from=>m.latents, :free=>false, :values=>1.0
      m.data_from_matrix(@cov_matrix,:cases=>@cases)
    end
  end
  it "should calculate SEM using openmx" do
    @sem.engine=:openmx
    @sem.name="Using OpenMx"
    @sem.compute.should be_true
  end
  it "should calculate SEM using sem" do
    @sem.engine=:sem
    @sem.name="Using SEM"
    @sem.compute.should be_true
  end
  
end

