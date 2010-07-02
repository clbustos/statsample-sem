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
end

