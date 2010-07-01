module Statsample
  class SEM
    class Model
      include Summarizable
      # Model based on covariance
      attr_reader :covariance_based
      # Covariance matrix
      attr_reader :covariance_matrix
      # Number of cases
      attr_accessor :cases
      # Name of cases
      attr_reader :covariance_matrix_fields
      def initialize(opts=Hash.new,&block)
        raise ArgumentError,"opts should be a Hash" if !opts.is_a? Hash
        default_opts={:name=>_("SEM Model")}
        @opts=default_opts.merge opts
        @paths=Hash.new
        if block
          block.arity<1 ? self.instance_eval(&block) : block.call(self)
        end
      end
      # Set one or more paths.
      # If array given in from and/or to options, equal number 
      # Rules
      # * from : variance-> from and to equal, label equal to "s^2 NAME_OF_FIELD", arrows=2, free=>true
      # * from and to: regression -> label equal to "FROM->TO", arrows=1, free=>true
      # * from, to, arrows -> regression or correlation -> label equal to "FROM->TO" if arrow=1,
      #   "FROM<->TO" if arrow=2, free=>true
      # * free=false -> requires values for each from - to value
      def path(opts)
        
      end
      def covariance_matrix_fields=(v)
        raise ArgumentError, "Should be size=#{@covariance_matrix.row_size}" if v.size!=@covariance_matrix.row_size
        @covariance_matrix_fields=v.map {|i| i.to_s}
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