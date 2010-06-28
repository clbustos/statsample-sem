$:.unshift(File.dirname(__FILE__)+"/.")
require 'spec_helper'

describe Statsample::SEM do
  before(:all) do
    begin 
      @data_path=File.dirname(__FILE__)+"/../data/demo_open_mx.ds"
      @ds=Statsample.load(@data_path)
    rescue 
      @data_path=File.dirname(__FILE__)+"/../data/demo_open_mx.csv"
      @ds=Statsample::CSV.read(@data_path)
    end
  end
  before(:each) do
    @sem=Statsample::SEM.new(:name=>'One Factor',:type=>'RAM')    
  end
  after(:each) do
    @sem.quit
  end
  it "#manifests correctly" do
    @sem.manifests @ds.fields
    @sem.manifests.should==@ds.fields
  end
  it "#latents correctlt" do
    @sem.latents ['G']
    @sem.latents.should==['G']
  end
  it "accepts paths" do
    @sem.path :from=>['G']
    @sem.paths.size.should==1
  end
  it "accepts a covariance matrix from dataset" do
    @sem.covariance_from_dataset @ds
    cov=Statsample::Bivariate.covariance_matrix(@ds)
    cov_from_dataset=@sem.r.eval("covariance_matrix").to_ruby
    cov.row_size.times do |i|
      cov.column_size.times do |j|
        cov[i,j].should be_close(cov_from_dataset[i,j], 1e-10)
      end
    end
  end
  it "accepts a covariance matrix directly" do
    cov=Statsample::Bivariate.covariance_matrix(@ds)
    @sem.covariance_from_matrix(cov,@ds.cases,@ds.fields)
    cov_from_dataset=@sem.r.eval("covariance_matrix").to_ruby
    cov.row_size.times do |i|
    cov.column_size.times do |j|
      cov[i,j].should be_close(cov_from_dataset[i,j], 1e-10)
    end
    end    
  end
  it "compute correctly" do
    @sem.manifests @ds.fields
    @sem.latents ['G']
    @sem.path :from=>@sem.latents, :to=>@sem.manifests, :labels=>@sem.manifests.map {|v| "to #{v}"}
    @sem.path :from=>@sem.manifests, :arrows=>2, :labels=>@sem.manifests.map {|v| "s2 #{v}"}
    @sem.path :from=>@sem.latents, :arrows=>2, :free=>false, :values=>1.0
    @sem.covariance_from_dataset @ds
    @sem.compute
    @sem.r.eval('manifests').to_ruby.should==@ds.fields
    @sem.r.eval('latents').to_ruby.should=='G'
    summary=@sem.summary
    summary['modelName'].should=="One Factor"
  end
end
