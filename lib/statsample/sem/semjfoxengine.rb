require 'rserve'
require 'tempfile'
module Statsample
  class SEM
    # SEM using J.Fox 'sem' R library.
    # Documentation for methods extracted from [http://davidakenny.net/cm/fit.htm]
    #
    class SemJFoxEngine
      include DirtyMemoize
      include Summarizable
      attr_accessor :summarizable
      attr_accessor :name
      def initialize(model,opts=Hash.new)
        @model=model
        defaults = {
          :name=>_("SEM analysis using J.Fox sem package")
        }
        @opts=defaults.merge opts
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
sem.object<-sem(sem.model,data, obs.variables=manifests, N=#{@model.cases});
sem.summary<-summary(sem.object)
        EOF
      end
      def compute
        raise "Insuficient information" unless @model.complete?
        r.assign 'manifests', @model.manifests
        r.assign 'data', @model.data_type==:raw ? @model.ds : @model.matrix
        if @model.matrix
          r.assign 'vn', @model.data_variables
          # We should assing names to fields on matrix
          r.void_eval('dimnames(data)<-list(vn,vn)')
        end
        r.void_eval r_query
        @r_summary=@r.eval('sem.summary').to_ruby
      end
      def r_summary
        if @r_summary.nil?
          compute
        end
        @r_summary
      end
      def graphviz
        require 'tmpdir'
        out=""
        compute if @r_summary.nil?
        Dir.mktmpdir {|dir| 
          filename=dir+="/model_#{Time.new.to_s}"
          r.void_eval("path.diagram(sem.object,output.type='dot',file='#{filename}')")
          
          file=File.open(filename+".dot","r") do |fp|
            out=fp.read
          end
        }
        out
      end
      # Chi-Square.
      #
      # For models with about 75 to 200 cases, this is a reasonable measure of fit.  But for models with more cases, the chi square is almost always statistically significant.  Chi square is also affected by the size of the correlations in the model: the larger the correlations, the poorer the fit.  
      def chi_square
        r_summary["chisq"]
      end
      # Degrees of freedom for Chi-Square
      def df
        r_summary["df"]
      end
      # Chi-Square for null model
      def chi_square_null
        r_summary["chisqNull"]
      end
      def df_null
        r_summary["dfNull"]
      end
      # Lisrel measure. Don't trust!
      def goodness_of_fit
        r_summary["GFI"]
      end
      # Lisrel measure. Don't trust!

      def adjusted_goodness_of_fit
        r_summary["AGFI"]
      end
      
      # Root Mean Square Error of Approximation (RMSEA)
      # 
      # This measure is based on the non-centrality parameter.  Its formula can be shown to equal:
      # 
      #   √[([χ2/df] - 1)/(N - 1)]
      # 
      # where N the sample size and df the degrees of freedom of the model.  (If χ2 is less than df, then RMSEA is set to zero.)  Good models have an RMSEA of .05 or less. Models whose RMSEA is .10 or more have poor fit. 
      # 
      def rmsea
        r_summary["RMSEA"][0]
      end
      def rmsea_confidence_interval
        r_summary["RMSEA"][1..2]
      end
      def rmsea_alpha
        r_summary["RMSEA"][3]
      end
      # ==Bentler-Bonett Index or Normed Fit Index (NFI).
      # 
      # Define the null model as a model in which all of the correlations or covariances are zero.  The null model is referred to as the "Independence Model" in AMOS.  Its formula is:
      # 
      #   [χ2(Null Model) - χ2(Proposed Model)]/ [χ2(Null Model)]
      # 
      # A value between .90 and .95 is acceptable, and above .95 is good. A disadvantage of this measure is that it cannot be smaller if more parameters are added to the model.  Thus, the more parameters added to the model, the larger the index.  It is for this reason that this measure is not recommended, but rather NNFI and CFI is used. 
      def nfi
        r_summary["NFI"]
      end

      # == Tucker Lewis Index or Non-normed Fit Index (NNFI).
      # 
      # A problem with the Bentler-Bonett NFI index is that there is no penalty for adding parameters.  The Tucker-Lewis index does have such a penalty.  Let χ2/df be the ratio of chi square to its degrees of freedom
      # 
      #   [χ2/df(Null Model) - χ2/df(Proposed Model)]/[χ2/df(Null Model) - 1]
      # 
      # If the index is greater than one, it is set at one.  It is interpreted as the Bentler-Bonett index.  Note than for a given model, a lower chi square to df ratio (as long as it is not less than one) implies a better fitting model.   
      def nnfi
        r_summary["NNFI"]
        
      end
      
      # ==Comparative Fit Index (CFI).
      # 
      # This measure is directly based on the non-centrality measure.  Let d = χ2 - df where df are the degrees of freedom of the model.  The Comparative Fit Index equals
      # 
      #   [d(Null Model) - d(Proposed Model)]/d(Null Model)
      # 
      # If the index is greater than one, it is set at one and if less than zero, it is set to zero. It is interpreted as the previous indexes.  If the CFI is less than one, then the CFI is always greater than the TLI.  CFI pays a penalty of one for every parameter estimated.   Note that the CFI depends on the average size of the correlations in the data.  If the average correlation between variables is not high, then the CFI will not be very high.         
      
      def cfi
        r_summary["CFI"]
        
      end
      def srmr
        r_summary["SRMR"]
        
      end
      
      # == Bayesian Information Criterion (BIC) and Adjusted BIC
      # 
      # the AIC pays a penalty of 2 for each parameter estimated.  The BIC and adjusted BIC increases the penalty as sample size increases
      # χ2 + [k(k - 1)/2 - df]ln(N)
      # 
      # where ln(N) is the natural logarithm of the number of cases in the sample.  The adjusted BIC replaces ln(N) with ln[(N + 2)/24].  The BIC places a high value on parsimony (perhaps too high).  The adjusted BIC, while placing a penalty for adding parameters based on sample, does not place as high a penalty as the BIC.  Like the AIC, these measures are not absolute measues and are used to compare the fit of two or more models estimated from the same data set.
      def bic
        r_summary["BIC"]
      end
      def normalized_residual
        r_summary["norm.res"]
      end
      def iterations
        r_summary['iterations']
      end
      def coefficients
        est=Hash.new
        coeffs= r_summary['coeff']
        coeffs[4].each_with_index do |v,i|
          v=~/(.+) (<---|<-->) (.+)/
          f1=$1
          f2=$3
          key=[f1,f2].sort
          est[key]={:estimate=>coeffs[0][i], :se=>coeffs[1][i], :z=>coeffs[2][i], :p=>coeffs[3][i], :label=>@model.get_label(key)}
        end
        est
      end
      def report_building(g)
        g.section(:name=>@name) do |s|
          s.text _("Manifests: %s") % @model.manifests.join(", ")
          s.text _("Latents  : %s") % @model.latents.join(", ")
          s.text "Chi-square: %0.3f (d.f=%d)" % [chi_square, df]
          g.table(:name=>_("Parameter estimation"),:header=>[_("From"), _("To"), _("Label"),  _("estimate"),_("se")]) do |t|
            @model.paths.sort.each do |v|
              
              f1,f2 = v[0][0],v[0][1]
              key=v[0]
              if v[1][:free]
                val=coefficients[key]
                label=v[1][:label]
                estimate="%0.8f" % val[:estimate]
                se="%0.8f" % val[:se]
              else
                label=_("%s (Fixed)") % v[1][:label]
                estimate=v[1][:value]
                se="--"
              end
              t.row [f1,f2, label, estimate, se] 
            end
          end
        end
      end
    end
  end
end