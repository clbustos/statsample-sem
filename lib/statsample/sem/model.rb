module Statsample
  class SEM
    class Model
      include Summarizable
      # Type of data used. Could be +:covariance+, +:correlation+ or +:data+
      attr_reader :data_type
      # Covariance/correlation matrix
      attr_reader :matrix
      # Raw data on a dataset
      attr_reader :ds
      # Number of cases
      attr_accessor :cases
      # Optional array of mean for use when data is matrix based
      attr_accessor :means
      # Name of variables
      attr_reader :variables
      
      attr_reader :paths
      def initialize(opts=Hash.new,&block)
        raise ArgumentError,"opts should be a Hash" if !opts.is_a? Hash
        default_opts={:name=>_("SEM Model")}
        @opts=default_opts.merge opts
        @paths=Hash.new
        if block
          block.arity<1 ? self.instance_eval(&block) : block.call(self)
        end
      end
      # True if model have enough information to process it
      def complete?
        !@data_type.nil? and !@manifests.nil? and !@latents.nil? and @paths.size>0
      end
      
      def add_path(f1,f2,arrows,free,values,labels,i)
        
        arrow_s = (arrows==1) ? "to":"cov"
        raise "Path repeated : #{f1},#{f2}" if @paths.has_key? [[f1,f2].sort]
        label= (labels.nil? or !labels.respond_to?:[] or labels[i].nil?) ? "#{f1} #{arrow_s} #{f2}" : labels[i]
        
        free_v = (free.is_a? Array) ? free[i] : free 
        if values.is_a? Array
          value= values[i].nil? ? nil : values[i]
        elsif values.is_a? Numeric
          value=values
        end
          
        value = nil if free_v
        
        @paths[[f1,f2].sort]={ :from=>f1, :to=>f2, :arrow=>arrows, :label=>label, :free=>free_v, :value=>value}
         i+=1 
        
        
      end
      # Set one or more paths. Based on OpenMx mxPath method.
      # 
      # ==Options:
      # * +:from+   : String or Array. sources of new paths
      # * +:to+     : String or Array. sinks of new paths
      # * +:all+    : bool. If you, connect all sources to all sinks. If false,
      # connect one-on-one sources to sinks if both are arrays, one source to
      # many sinks if +:from+ is a String and +:to+ is an Array
      # * +:arrows+ : 1 for regression, 2 for variance-covariance. See rules
      # for specific automatic setting
      # * +:free+   : Indicates whether paths are free or fixed. By default, true
      # * +:values+ : The starting values of the parameters
      # * +:labels+ : The names of paths
      # ==Rules
      # * from : variance-> from and to equal, label equal to "s^2 NAME_OF_FIELD", arrows=2, free=>true
      # * from and to: regression -> label equal to "FROM->TO", arrows=1, free=>true
      # * from, to, arrows -> label equal to "FROM->TO" if arrows=1,
      # "FROM<->TO" if arrows=2, free=>true
      # * free=false -> requires values for each from - to value
      
      def path(opts)
        raise "Requires at least :from option" unless opts.has_key? :from
        
        free=true
        all=false
        
        from=opts[:from]
        to=opts[:to]
        
        all=opts[:all] if opts.has_key? :all
        free=opts[:free] if opts.has_key? :free

        labels=opts[:labels]
        arrows=opts[:arrows]
        
        values=opts[:values]
        from=[from] if from.is_a? String
        to||=from
        to=[to] if to.is_a? String
        
        if from==to # variances
          arrows||=2
          labels_2=Array.new(from.size)
          
          from.each_with_index do |f,i|
            labels_2[i]=(labels.nil? or !labels.respond_to?:[] or labels[i].nil?) ? "var #{f}" : labels[i]
          end
          
          from.each_with_index do |f,i|
            add_path(f,f,arrows,free,values, labels_2,i)
          end
        else # regression and covariances
          arrows||=1
          i=0
          all=true if from.size==1 or to.size==1
          if all
            from.each do |f1|
              to.each do |f2|
                add_path(f1,f2,arrows,free,values,labels,i)
                i+=1 
              end
            end
          else
            raise ":from and :to should be the same size" if from.size!=to.size
            from.size.times.each do |i|
              add_path(from[i],to[i],arrows,free,values,labels,i)
            end
            
          end
          
        end
        
        
      end
      def variables=(v)
        raise ArgumentError, "Should be size=#{@variables.row_size}" if @data_type!=:raw and v.size!=@matrix.row_size
        @variables=v.map {|i| i.to_s}
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
      def data_from_dataset(ds)
        @data_type=:raw
        @ds=ds
        @variables=@ds.fields
      end
      
      def data_from_matrix(matrix,opts=Hash.new)
        type = opts[:type]
        type||=(matrix.respond_to? :type) ? matrix.type : :covariance
        variable_names = opts[:variable_names]
        cases = opts[:cases]
        means = opts[:means]
        raise "You should set number of cases" if cases.nil?
        
        @data_type= (type==:covariance) ? :covariance : :correlation
        @matrix=matrix
        @cases=cases
        @means=means
        if variable_names.nil? 
          @variables=@matrix.fields if @matrix.respond_to? :fields
        else
          @variables=variable_names
        end
      end
    end
  end
end