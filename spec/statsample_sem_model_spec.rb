$:.unshift(File.dirname(__FILE__)+"/.")
require 'spec_helper'

describe Statsample::SEM::Model do
  before(:all) do
    begin 
      @data_path=File.dirname(__FILE__)+"/fixtures/demo_open_mx.ds"
      @ds=Statsample.load(@data_path)
    rescue 
      @data_path=File.dirname(__FILE__)+"/fixtures/demo_open_mx.csv"
      @ds=Statsample::CSV.read(@data_path)
    end
  end

  before(:each) do
    @model=Statsample::SEM::Model.new
  end
  it "method manifests= should set manifests" do
    @model.manifests=@ds.fields
    @model.manifests.should==@ds.fields
  end
  it "method manifests with argument should set manifests" do
    @model.manifests @ds.fields
    @model.manifests.should==@ds.fields
  end
  it "method latents= should set latents" do
    @model.latents=["G"]
    @model.latents.should==["G"]
  end
  it "method latents with argument should set latents" do
    @model.latents ["G"]
    @model.latents.should==["G"]
  end
  
  
end