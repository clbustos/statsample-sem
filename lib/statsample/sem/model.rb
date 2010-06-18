module Statsample
  class SEM
    class Model
      include Summarizable
      attr_reader :covariance_based
      attr_reader :covariance_matrix
      attr_accessor :cases
      attr_accessor :covariance_matrix_fields
      def initialize(opts=Hash.new,&block)
        raise ArgumentError,"opts should be a Hash" if !opts.is_a? Hash
        default_opts={:name=>_("SEM Model")}
        @opts=default_opts.merge opts        
        if block
          block.arity<1 ? self.instance_eval(&block) : block.call(self)
        end
      end
      def latents(*argv)
        if argv.size==0
          @latents
        elsif argv[0].is_a? Array 
          @latents=argv[0]
        else
          @latents=[argv]
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
          @manifests=[argv]
        end
      end
      def manifests=(argv)
        @manifests=argv
      end
      def covariance_from_dataset(ds)
        @covariance_based=true
        ds2=ds.clone_only_valid
        @covariance_matrix=Statsample::Bivariate.covariance_matrix(ds2)
        @cases=ds2.cases
        @covariance_matrix_fields=ds2.fields if ds2.respond_to? :fields
      end
      
      def covariance_from_matrix(matrix,cases,fields=nil)
        @covariance_based=true
        @covariance_matrix=matrix
        @cases=cases
        if fields.nil? 
          @covariance_matrix_fields=ds2.fields if ds2.respond_to? :fields
        else
          @covariance_matrix_fields=fields
        end
      end
    end
  end
end