=begin
  Converts everything into the smallest common units.


  area: square feet
  length: feet
=end

module Teleos
  # Performs unit conversions between numbers.
  # Only useful for two-argument conversions, but can accept any number.
  # 1.perform_conversions('acres','hectares')
  # (3.5).perform_conversions('years', 'quarters')
  
  module ConvertableNumber
    @@core_conversions = {
      :area => {
        'acres'         => 43560,
        'hectares'      => 107639.104,
        'sf'            => 1,
        'si'            => 0.0069444444444,
        'square_feet'   => 1,
        'square_inches' => 0.0069444444444,
        'square_meters' => 10.7639104,
        'square_miles'  => 27878400
        
      },
      :length => {
        'inches'        => 0.083333333333,
        'feet'          => 1,
        'centimeters'   => 0.032808399,
        'decimeters'    => 0.32808399,
        'meters'        => 3.2808399,
        'microparsecs'  => 101236229000,
        'miles'         => 5280,
        'millimeters'   => 0.0032808399,
        'pdf_points'    => 0.0093000186,
        'rods'          => 16.5
        
      },
      :time => {
        'years'         => 12,
        'quarters'      => 3,
        'months'        => 1
      }
    }
    
    def feet_and_inches
      _ = self.to_feet_and_inches
      %Q{#{_[:feet]}'#{_[:inches]}\"}
    end
    
    # conversions_requested: a list of conversions to perform.
    # Performs left-to-right type conversions of the first detected measurement type and returns the float result.
    def perform_conversions(first_conversion, last_conversion)
      conversion_type = nil
      @@core_conversions.each_pair do |k, conv|
        next unless conv.has_key?(first_conversion) || conv.has_key?(first_conversion.pluralize)
        conversion_type = k
      end
      if conversion_type
        numval = @@core_conversions[conversion_type][first_conversion] || @@core_conversions[conversion_type][first_conversion.pluralize]
        raise "Cannot find first conversion: #{first_conversion} (using #{conversion_type})!" unless numval
        retval = self.to_f * numval
        raise "Conversion not found: #{first_conversion} to #{last_conversion}!" unless @@core_conversions[conversion_type].has_key?(last_conversion)
        retval /= @@core_conversions[conversion_type][last_conversion]
        return retval
      else
        raise "Cannot Convert!"
      end
    end
    
    
    def to_feet_and_inches
      _feet = (self / 12).to_i
      _inches = (self.to_i % 12)
      {:feet => _feet, :inches => _inches}
    end

#    def method_missing(sym, *args)
#      k = sym.to_s
#      if k =~ /\w+_to_/
#        conversions_requested = k.split(/_to_/)
#        return perform_conversions(*conversions_requested)
#      else
#        super(sym, *args)
#      end
#    end
  end
end

class Numeric
  include Teleos::ConvertableNumber
end