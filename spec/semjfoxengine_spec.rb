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
    before(:all) do
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
    it "should have valid std coeffs" do
      sc=@engine.standarized_coefficients
      sc.should be_instance_of Hash
      sc[['G','x1']][:estimate].should be_close(0.891309,0.0001)
    
    end
    it "should return a valid summary" do
      @engine.summary.size>0
    end

    it "should compute and return well formed response" do
      lambda{@engine.compute}.should_not raise_error
      @engine.r_summary.should be_instance_of (Array)
    end
    it "should return a valid graphviz definition for model" do
      @engine.graphviz.should match "digraph"
    end
    
# Model Chisquare =  7.384   Df =  5 Pr(>Chisq) = 0.19361
# Chisquare (null model) =  3725.1   Df =  10
# Goodness-of-fit index =  0.99426
# Adjusted goodness-of-fit index =  0.98277
# RMSEA index =  0.030911   90% CI: (NA, 0.074569)
# Bentler-Bonnett NFI =  0.99802
# Tucker-Lewis NNFI =  0.99872
# Bentler CFI =  0.99936
# SRMR =  0.0032191
# BIC =  -23.689 
    
    it "method chi_square return X^2 of model" do 
      @engine.chi_square.should be_close(7.384,0.001)
    end
    it "method df return degrees of freedom of model" do 
      @engine.df.should==5
    end
    it "method chi_square_null return X^2 of null model" do 
      @engine.chi_square_null.should be_close(3725.0596,0.001)
    end
    it "method df_null return degrees of freedom for null model" do
      @engine.df_null.should==10
    end
    it "method goodness_of_fit return GFI" do
      @engine.goodness_of_fit.should be_close(0.99426, 0.0001)
    end
    it "method adjusted_goodness_of_fit return AGFI" do
      @engine.adjusted_goodness_of_fit.should be_close(0.98277, 0.0001)
    end
    it "method rmsa and derivatives returns... RMSEA!" do
      @engine.rmsea.should be_close(0.030911, 0.0001)
      @engine.rmsea_alpha.should==0.90
      @engine.rmsea_confidence_interval[0].should be_nil
      @engine.rmsea_confidence_interval[1].should be_close(0.074569, 0.0001)
    end
    it "method nfi returns NFI" do
      @engine.nfi.should be_close(0.99802, 0.0001)
    end
    it "method nnfi returns NNFI" do
      @engine.nnfi.should be_close(0.99872, 0.0001)
    end
    it "method cfi returns CFI" do
      @engine.cfi.should be_close(0.99936, 0.0001)
    end
    it "method srmr returns SRMR" do
      @engine.srmr.should be_close(0.0032191, 0.0001)
    end
    it "method bic returns BIC" do
      @engine.bic.should be_close(-23.689, 0.001)
    end
    it "method iterations returns the number of iterations" do
      @engine.iterations.should==30
    end
    
    # G to x1 0.397152 0.0155826 25.4869 0        x1 <--- G 
    # G to x2 0.503662 0.0182767 27.5576 0        x2 <--- G 
    # G to x3 0.577242 0.0204998 28.1584 0        x3 <--- G 
    # G to x4 0.702774 0.0240755 29.1905 0        x4 <--- G 
    # G to x5 0.796251 0.0267431 29.7741 0        x5 <--- G 
    # var x1  0.040814 0.0028254 14.4455 0        x1 <--> x1
    # var x2  0.038020 0.0028185 13.4893 0        x2 <--> x2
    # var x3  0.040827 0.0031653 12.8986 0        x3 <--> x3
    # var x4  0.039387 0.0034217 11.5110 0        x4 <--> x4
    # var x5  0.036287 0.0036916  9.8296 0        x5 <--> x5    
    it "coefficients returns a hash of Parameter estimates" do
      coeffs=@engine.coefficients
      coeffs[['G','x1']][:estimate].should be_close(0.397152, 0.00001)
      coeffs[['G','x1']][:se].should be_close(0.0155826, 0.00001)
      coeffs[['G','x1']][:z].should be_close(25.4869, 0.0001)
      coeffs[['G','x1']][:label].should=='G to x1'
    end
    
    
  end
  
  
end

