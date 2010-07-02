require 'rserve'
require 'tempfile'
module Statsample
  class SEM
    class OpenMxEngine
      include Summarizable
      attr_accessor :summarizable
      attr_accessor :name
      attr_reader :summary
      def initialize(model,opts=Hash.new)
        @model=model
        defaults = {
          :name=>_("SEM analysis using OpenMx")
        }
        @opts=defaults.merge defaults
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
          r.assign 'vn', @model.variables
          # We should assing names to fields on matrix
          r.void_eval('dimnames(data)<-list(vn,vn)')
        end
        r.assign 'manifests',@model.manifests
        r.assign 'latents', @model.latents
        r.assign 'd_means',@model.means unless @model.means.nil?
        r.void_eval r_query
        @summary=@r.eval('summary(factorFit)').to_ruby
      end
      def graphviz
        compute if @summary.nil?
        tf=Tempfile.new('model.dot')
        r.void_eval("omxGraphviz(factorModel,'#{tf.path}')")
#        tf.close
#        tf.open
        tf.read
      end
    end
  end
end
