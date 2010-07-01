require 'rinruby'
module Statsample
  class SEM
    class OpenMxEngine
      include Summarizable
      attr_accessor :summarizable
      attr_accessor :name
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
          value= path[:value] ? ", values=#{path[:value]}":""
          label= path[:label] ? ", labels='#{path[:label]}'" : ""  
          "mxPath(from=c('#{path[:from]}'), to=c('#{path[:to]}'), arrows=#{path[:arrow]}, free=#{path[:free] ? "TRUE" : "FALSE"} #{value} #{label}"
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
        means=(@model.data_type!=:raw and !@model.means.nil?) ? ", means = d_means" : ""
        num=(@model.data_type!=:raw) ? ", numObs = #{@model.cases}" : ""
        
        "mxData( observed=data, type='#{type}' #{means} #{num})"
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
#{r_mxdata});
factorFit<-mxRun(factorModel);
rm(data,manifests,latents,means);
        EOF
      end
      def compute
        raise "Insuficient information" unless @model.complete?
        r.assign 'data', @model.data_type==:raw ? @model.ds : @model.matrix
        r.assign 'manifests',@model.manifests
        r.assign 'latents', @model.latents
        r.assign 'd_means',@model.means unless @model.means.nil?
        r.eval "try(#{r_query})"
        end
    end
  end
end
