require 'rserve'
require 'tempfile'
module Statsample
  class SEM
    class OpenMxEngine < Engine
      include Summarizable
      attr_accessor :summarizable
      attr_accessor :name
      def initialize(model,opts=Hash.new)
        @model=model
        defaults = {
          :name=>_("SEM analysis using OpenMx")
        }
        @opts=defaults.merge opts
        @name=@opts[:name]
      end
      def r
        @r||=Rserve::Connection.new
      end
      def r_mxpaths
        @model.paths.values.map {|path|
          value= path[:value] ? ", values = #{path[:value]}":""
          label= path[:label] ? ", labels = \"#{path[:label]}\"" : ""  
          "mxPath(from=c(\"#{path[:from]}\"), to=c(\"#{path[:to]}\"), arrows = #{path[:arrow]}, free = #{path[:free] ? "TRUE" : "FALSE"} #{value} #{label})"
        }.join(",\n")
      end
      def r_mxdata
        type=case @model.data_type
          when :raw
            'raw'
          when :covariance
            'cov'
          when :correlation
            'cor'
        end
        means=(@model.data_type!=:raw and !@model.means.nil?) ? ", means = d_means " : ""
        num=(@model.data_type!=:raw) ? ", numObs = #{@model.cases} " : ""
        
        "mxData(observed=data, type='#{type}' #{means} #{num})"
      end
        
      def r_query
        <<-EOF
library(OpenMx);
factorModel <- mxModel(
name="#{name}",
type="RAM",
manifestVars = manifests,
latentVars = latents,
#{r_mxpaths}, 
#{r_mxdata}
);
factorFit<-mxRun(factorModel);
rm(data,manifests,latents,d_means);
        EOF
        #p r.eval('factorFit').to_ruby
      end
      
      def compute
        raise "Insuficient information" unless @model.complete?
        r.assign 'data', @model.data_type==:raw ? @model.ds : @model.matrix
        if @model.matrix
          r.assign 'vn', @model.data_variables
          # We should assing names to fields on matrix
          r.void_eval('dimnames(data)<-list(vn,vn)')
        end
        r.assign 'manifests',@model.manifests
        r.assign 'latents', @model.latents
        r.assign 'd_means',@model.means unless @model.means.nil?
        r.void_eval r_query
        @r_summary=@r.eval('summary(factorFit)').to_ruby
        
      end
      def graphviz
        compute if @r_summary.nil?
        tf=Tempfile.new('model.dot')
        r.void_eval("omxGraphviz(factorModel,'#{tf.path}')")
#        tf.close
#        tf.open
        tf.read
      end
      def r_summary
        @r_summary||=compute
      end
      def chi_square
        r_summary['Chi']
      end
      def df
        r_summary['degreesOfFreedom']
      end
      def chi_square_null
        null_model.r_summary['Chi']
      end
      def df_null
        null_model.r_summary['degreesOfFreedom']
      end

      def null_model
        @null_model||=compute_null_model
      end
      def compute_null_model #:nodoc:
        nm=@model.dup
        nm.make_null
        (self.class).new(nm,@opts)
      end
      def rmsea
        r_summary['RMSEA']
      end
       # [χ2(Null Model) - χ2(Proposed Model)]/ [χ2(Null Model)]
      def nfi
        (chi_square_null-chi_square).quo(chi_square_null)
      end
      
      # [χ2/df(Null Model) - χ2/df(Proposed Model)]/[χ2/df(Null Model) - 1]
      def nnfi
        (chi_square_null.quo(df_null) - chi_square.quo(df)).quo(chi_square_null.quo(df_null)-1)
      end
      def cfi
        d_null=chi_square_null-df_null
        ((d_null)-(chi_square-df)).quo(d_null)
      end
      def bic
        raise "Not well implemented"
        k=@model.k
        ln_n=Math.log(@model.cases)
        chi_square+((k*(k-1).quo(2)) - df)*ln_n
      end
      def coefficients
        @coefficients||=compute_coefficients
      end
      def compute_coefficients #:nodoc:
        est=Hash.new
        coeffs=r_summary['parameters']
        # 0:name, 1:matrix, 2:row, 3:col, 4:estimate, 5:Std.error
        coeffs[0].each_with_index do |v,i|
          f1=coeffs[2][i]
          f2=coeffs[3][i]
          key=[f1,f2].sort
          est[key]={:estimate=>coeffs[4][i], :se=>coeffs[5][i], :z=>coeffs[4][i].quo(coeffs[5][i]), :p=>nil, :label=>v}
        end
        est
        
      end
      def report_building(g)
        g.section(:name=>@name) do |s|
          common_summary(s)
        end
      end

    end
  end
end
