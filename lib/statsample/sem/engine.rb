module Statsample
  class SEM
    # abstract engine for SEM classes
    class Engine
      def common_summary(s)
        s.text _("Manifests: %s") % @model.manifests.join(", ")
        s.text _("Latents  : %s") % @model.latents.join(", ")
        s.text "Chi-square: %0.3f (d.f=%d), p = %0.5f " % [chi_square, df, (1-Distribution::ChiSquare.cdf(chi_square, df))]
        s.table(:name=>_("Parameter estimation"),:header=>[_("From"), _("To"), _("Label"),  _("estimate"),_("se"), _("z")]) do |t|
          @model.paths.sort.each do |v|
            
            f1,f2 = v[0][0],v[0][1]
            key=v[0]

            if v[1][:free]
              val=coefficients[key]
              raise "Doesn't have coefficient #{key}" if val.nil?
              label=v[1][:label]
              estimate = val[:estimate].nil? ? "?" : "%0.5f" % val[:estimate]
              se=val[:se].nil? ? "?" : ("%0.5f" % val[:se])
              
              z=(val[:z].nil? or val[:p].nil?) ? "?" : ("%0.3f%s(%0.2f)" % [val[:z], val[:z].abs>=1.96 ? "*":"", val[:p]]) 
            else
              label=_("%s (Fixed)") % v[1][:label]
              estimate=v[1][:value]
              se="--"
              z="--"
            end
            t.row [f1,f2, label, estimate, se, z] 
          end
        end
        
        def summary_standarized_coefficients_table(s)
        s.table(:name=>_("Standarized coefficients"),:header=>[_("From"), _("To"), _("Label"),  _("estimate")]) do |t|
          @model.paths.sort.each do |v|
            f1,f2 = v[0][0],v[0][1]
            key=v[0]
            if v[1][:free]
              val=standarized_coefficients[key]
              label=v[1][:label]
              estimate=val[:estimate].nil? ? "?" : "%0.5f" % val[:estimate]
            else
              label=_("%s (Fixed)") % v[1][:label]
              estimate=v[1][:value]
            end
            t.row [f1,f2, label, estimate] 
          end
        end
      end
        
      end
    end
  end
end