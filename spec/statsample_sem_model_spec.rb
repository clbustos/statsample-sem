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
  
  
  
  
  it "method path with :from should create a variance path" do
    @model.path :from=>"x1"
    @model.paths.should=={
      ['x1','x1']=>{:from=>'x1',:to=>'x1',:arrow=>2,:label=>'s^2 x1', :free=>true, :value=>nil}
    }
  end
  it "method path with :from and :two should create a regression path" do
    @model.path :from=>"G", :to=>'x1'
    @model.paths.should=={
      ['G','x1']=>{:from=>'G',:to=>'x1',:arrow=>1,:label=>'G --> x1', :free=>true, :value=>nil}
    }
  end
  it "method path with :from, :two and arrows should set label automaticly" do
    @model.path :from=>"G", :to=>'x1', :arrows=>1
    @model.path :from=>"G", :to=>'x2', :arrows=>2

    @model.paths.should=={
      ['G','x1']=>{:from=>'G',:to=>'x1',:arrow=>1,:label=>'G --> x1', :free=>true, :value=>nil},
      ['G','x2']=>{:from=>'G',:to=>'x2',:arrow=>2,:label=>'G <-> x2', :free=>true, :value=>nil}
    }
  end 
  it "method path should label correctly" do
    @model.path :from=>"G", :to=>['x1','x2','x3'], :labels=>['to x1','to x2']
    @model.paths.should=={
      ['G','x1']=>{:from=>'G',:to=>'x1',:arrow=>1,:label=>'to x1', :free=>true, :value=>nil},
      ['G','x2']=>{:from=>'G',:to=>'x2',:arrow=>1,:label=>'to x2', :free=>true, :value=>nil},
      ['G','x3']=>{:from=>'G',:to=>'x3',:arrow=>1,:label=>'G --> x3', :free=>true, :value=>nil}
    }
  end 
  
  
  
  it "method path with free array set values in proper order" do
    @model.path :from=>"G", :to=>['x1','x2','x3'], :free=>[false,true,false], :values=>[1,2,3]
    @model.paths.should=={
      ['G','x1']=>{:from=>'G',:to=>'x1',:arrow=>1,:label=>'G --> x1', :free=>false, :value=>1},
      ['G','x2']=>{:from=>'G',:to=>'x2',:arrow=>1,:label=>'G --> x2', :free=>true, :value=>nil},
      ['G','x3']=>{:from=>'G',:to=>'x3',:arrow=>1,:label=>'G --> x3', :free=>false, :value=>3}
    }
  end
  it "method path with free array set scalar value in proper order" do
    @model.path :from=>"G", :to=>['x1','x2','x3'], :free=>[false,true,false], :values=>1.0
    @model.paths.should=={
      ['G','x1']=>{:from=>'G',:to=>'x1',:arrow=>1,:label=>'G --> x1', :free=>false, :value=>1.0},
      ['G','x2']=>{:from=>'G',:to=>'x2',:arrow=>1,:label=>'G --> x2', :free=>true, :value=>nil},
      ['G','x3']=>{:from=>'G',:to=>'x3',:arrow=>1,:label=>'G --> x3', :free=>false, :value=>1.0}
    }
  end
  
  
  describe "with multiple in and outs" do
    it "should set correctly 1 in, multiple outs" do
      @model.path :from=>"G", :to=>['x1','x2']
      @model.paths.should=={
        ['G','x1']=>{:from=>'G',:to=>'x1',:arrow=>1,:label=>'G --> x1', :free=>true, :value=>nil},
        ['G','x2']=>{:from=>'G',:to=>'x2',:arrow=>1,:label=>'G --> x2', :free=>true, :value=>nil}
      }
    end
    it "should set correctly multiple ins, 1 out" do
      @model.path :from=>["x1","x2"], :to=>['x3']
      @model.paths.should=={
        ['x1','x3']=>{:from=>'x1',:to=>'x3',:arrow=>1,:label=>'x1 --> x3', :free=>true, :value=>nil},
        ['x2','x3']=>{:from=>'x2',:to=>'x3',:arrow=>1,:label=>'x2 --> x3', :free=>true, :value=>nil}
      }
    end
    it "should set correctly multiple ins, multiples outs, with :all=>false" do
      @model.path :from=>["x1","x2"], :to=>['x3','x4']
      @model.paths.should=={
        ['x1','x3']=>{:from=>'x1',:to=>'x3',:arrow=>1,:label=>'x1 --> x3', :free=>true, :value=>nil},
        ['x2','x4']=>{:from=>'x2',:to=>'x4',:arrow=>1,:label=>'x2 --> x4', :free=>true, :value=>nil}
      }
    end
    it "should set correctly multiple ins, multiples outs, with :all=>true" do
      @model.path :from=>["x1","x2"], :to=>['x3','x4'], :all=>true
      @model.paths.should=={
        ['x1','x3']=>{:from=>'x1',:to=>'x3',:arrow=>1,:label=>'x1 --> x3', :free=>true, :value=>nil},
        ['x1','x4']=>{:from=>'x1',:to=>'x4',:arrow=>1,:label=>'x1 --> x4', :free=>true, :value=>nil},
        ['x2','x3']=>{:from=>'x2',:to=>'x3',:arrow=>1,:label=>'x2 --> x3', :free=>true, :value=>nil},

        ['x2','x4']=>{:from=>'x2',:to=>'x4',:arrow=>1,:label=>'x2 --> x4', :free=>true, :value=>nil}
      }
    end
  end
  
  it "should accept a dataset" do
    @model.data_from_dataset(@ds)
    @model.data_type.should==:raw
    @model.ds.should==@ds
    @model.variables.should==@ds.fields
  end
  it "should accept a covariance matrix" do
    @model.data_from_matrix(Statsample::Bivariate.covariance_matrix(@ds), :cases=>@ds.dup_only_valid.cases)
    @model.data_type.should==:covariance
    @model.cases.should==@ds.cases
    @model.variables.should==@ds.fields
    
    
  end
  it "should accept a correlation matrix" do
    @model.data_from_matrix(Statsample::Bivariate.correlation_matrix(@ds), :cases=>@ds.dup_only_valid.cases)
    @model.data_type.should==:correlation
    @model.cases.should==@ds.cases
    @model.variables.should==@ds.fields
    
    
  end
  
end