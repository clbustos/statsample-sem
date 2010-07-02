require 'rserve'
require 'tempfile'
module Statsample
  class SEM
    class SemJFoxEngine
      include Summarizable
      attr_accessor :summarizable
      attr_accessor :name
      attr_reader :summary
      def initialize(model,opts=Hash.new)
        @model=model
        defaults = {
          :name=>_("SEM analysis using J.Fox sem package")
        }
        @opts=defaults.merge defaults
        @name=@opts[:name]
      end
      def r
        @r||=Rserve::Connection.new
      end
      def r_sempaths
        @model.paths.values.map {|path|
          sign=(path[:arrow]==1) ? " ->" : "<->"
          label= path[:label] ? path[:label]  : "NA"  

          label_and_value=(path[:free]) ? "'#{label}', NA" : "NA, #{path[:value]}"
          "'#{path[:from]} #{sign} #{path[:to]}', #{label_and_value}"
        }.join(",\n")
      end
      def r_semdata
        type=case @model.data_type
          when :raw
            raise "Not implemented"
          when :covariance
            'cov'
          when :correlation
            raise "not implemented"
        end
      end
def r_query
        <<-EOF
library(sem);
sem.model<-matrix(c(
#{r_sempaths}
),
ncol=3,byrow=TRUE)
sem.object<-sem(sem.model,data, N=#{@model.cases});
sem.summary<-summary(sem.object)
        EOF
      end
      def compute
        raise "Insuficient information" unless @model.complete?
        r.assign 'data', @model.data_type==:raw ? @model.ds : @model.matrix
        if @model.matrix
          r.assign 'vn', @model.variables
          # We should assing names to fields on matrix
          r.void_eval('dimnames(data)<-list(vn,vn)')
        end
        r.void_eval r_query
        @summary=@r.eval('sem.summary').to_ruby
      end
    end
  end
end