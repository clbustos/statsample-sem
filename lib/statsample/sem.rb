require 'rserve'

module Statsample
  class SEM
    VERSION='0.0.1'
    attr_reader :paths
    attr_reader :name
    attr_reader :type
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
    def r
      @r||=Rserve::Connection.new
    end
    def compute
      raise "Insuficient information" if @manifests.nil? or @latents.nil? or @paths.size<1
      r.assign 'manifests',@manifests
      r.assign 'latents', @latents
      query= <<-EOF
library(OpenMx)
factorModel <- mxModel(name="#{name}",
type="#{type}",
manifestVars = manifests,
latentVars = latents,
#{r_paths},
#{r_data}
)
factorFit<-mxRun(factorModel)
      EOF
      r.eval query
    end
    def ary_to_r(ary)
      "c("+ary.map {|v| 
        val_to_r(v)
      }.join(',')+")"
    end
    def val_to_r(v)
      
      if v==true
        "TRUE"
      elsif v==false
        "FALSE"
      elsif v.is_a? Numeric
        v.to_s
      else
        "'#{v.to_s}'"
      end
    end
      
    def hash_to_r(h)
      h.map {|k,v|
        k.to_s+"="+(v.is_a?(Array) ? ary_to_r(v) : val_to_r(v)) 
      }.join(", ")
    end
    def r_paths
      r_code=@paths.map do |path|
        "mxPath("+hash_to_r(path)+")"
      end
      r_code.join(",\n")
    end
    def quit
      r.close unless @r.nil?
    end
    def r_data
      if(@covariance_based)
      "mxData(observed=covariance_matrix, type='cov', numObs=#{@cases})"
      else
        raise "Only implemented with covariance from a dataset"
      end
    end
    def covariance_from_dataset(ds)
      @covariance_based=true
      ds2=ds.clone_only_valid
      cov=Statsample::Bivariate.covariance_matrix(ds2)
      @cases=ds2.cases
      r.assign 'covariance_matrix',cov
      fields=ary_to_r(ds2.fields)
      r.eval("dimnames(covariance_matrix)<-list(#{fields},#{fields})")
    end
    def covariance_from_matrix(matrix,cases,fields)
      @covariance_based=true
      r.assign 'covariance_matrix', matrix
      @cases=cases
      r_fields=ary_to_r(fields)
      r.eval("dimnames(covariance_matrix)<-list(#{r_fields},#{r_fields})")
      
    end
    def summary
      r.eval('summary(factorFit)').to_ruby
      
    end
    def path(p1=Hash.new)
      raise "path should have at least a :from option" unless p1.has_key? :from
      @paths << p1
    end
    def latents(*argv)
      if argv.size==0
        @latents
      elsif argv[0].is_a? Array 
        @latents=argv[0]
      else
        @latents=argv
      end
    end
    def latents=(argv)
      @latents=argv
    end
      
    def manifests(*argv)
      if argv.size==0
        @manifests
      elsif argv[0].is_a? Array 
        @manifests=argv[0]
      else
        @manifests=argv
      end
    end
    def manifests=(argv)
      @manifests=argv
    end
  end
end