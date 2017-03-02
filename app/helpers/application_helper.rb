module ApplicationHelper
    
    def convert_frequency(amount, old = "Fortnightly", new = "Weekly")
        conversion_factor = {   week: {
                                    week:       1.0,
                                    fortnight:  2.0,
                                    month:      52.0/12.0,
                                    quarter:    52.0/4.0,
                                    year:       52.0
                                    },
                                fortnight: {
                                    week:       0.5,
                                    fortnight:  1.0,
                                    month:      26.0/12.0,
                                    quarter:    26.0/4.0,
                                    year:       26.0
                                },
                                month: {
                                    week:       12.0/52.0,
                                    fortnight:  12.0/26.0,
                                    month:      1.0,
                                    quarter:    3.0,
                                    year:       12.0
                                },
                                quarter: {
                                    week:       4.0/52.0,
                                    fortnight:  4.0/26.0,
                                    month:      4.0/12.0,
                                    quarter:    1.0,
                                    year:       4.0
                                },
                                year: {
                                    week:       1.0/52.0,
                                    fortnight:  1.0/26.0,
                                    month:      1.0/12.0,
                                    quarter:    1.0/4.0,
                                    year:       1.0
                                }
        }
        from_freq = old.downcase.chomp('ly').to_sym
        to_freq = new.downcase.chomp('ly').to_sym
        
        amount * conversion_factor[from_freq][to_freq]
    end
    
    def convert_to_fortnightly (amt, freq)
        
        if freq == "Weekly"
            return amt * 2.0
        elsif freq == "Fortnightly"
            return amt
        elsif freq == "Monthly"
            return (amt * 12.0)/26.0
        elsif freq == "Yearly"
            return amt / 26.0
        else
            return 0
        end
    end
    
    def convert_to_weekly(amount, freq)
        convert_to_fortnightly(amount, freq) / 2.0
    end
    
    def convert_to_monthly(amount, freq)
        convert_to_fortnightly(amount, freq) * 26.0 / 12.0 
    end
    
    def convert_to_yearly(amount, freq)
        convert_to_fortnightly(amount, freq) * 26.0
    end
    
    def calculate_tax(amount, freq = 'Fortnightly', hecs = false, threshold = true)
        
        tables = Hash.new
        
        coefficients_table_1 = Array.new
        hecs_table_1 = Array.new
        
        coefficients_table_1 << [355,   0, 0]
        coefficients_table_1 << [410,   0.1900, 67.4635 ]
        coefficients_table_1 << [512,   0.2900, 108.4923]
        coefficients_table_1 << [711,   0.2100, 67.4646 ]
        coefficients_table_1 << [1282,  0.3477, 165.4435]
        coefficients_table_1 << [1673,  0.3450, 161.9819]
        coefficients_table_1 << [3461,  0.3900, 237.2704]
        coefficients_table_1 << [99999, 0.4900, 583.4242]
        
        coefficients_table_2 = Array.new
        
        coefficients_table_2 << [60,    0.1900, 0.1900  ]
        coefficients_table_2 << [361,   0.2332, 2.6045  ]
        coefficients_table_2 << [932,   0.3477, 44.0006 ]
        coefficients_table_2 << [1323,  0.3450, 41.4841 ]
        coefficients_table_2 << [3111,  0.3900, 101.0225]
        coefficients_table_2 << [99999, 0.4900, 412.1764]
        
        tables[:tax] = { threshold: coefficients_table_1, no_threshold: coefficients_table_2 }

        hecs_table_1 << [1054.99, 0.000]
        hecs_table_1 << [1174.99, 0.040]
        hecs_table_1 << [1294.99, 0.045]
        hecs_table_1 << [1362.99, 0.050]
        hecs_table_1 << [1464.99, 0.055]
        hecs_table_1 << [1586.99, 0.060]
        hecs_table_1 << [1670.99, 0.065]
        hecs_table_1 << [1838.99, 0.070]
        hecs_table_1 << [1958.99, 0.075]
        hecs_table_1 << [9999.99, 0.080]
        
        hecs_table_2 = Array.new
        
        hecs_table_2 << [ 704.99, 0.000]
        hecs_table_2 << [ 824.99, 0.040]
        hecs_table_2 << [ 944.99, 0.045]
        hecs_table_2 << [1012.99, 0.050]
        hecs_table_2 << [1114.99, 0.055]
        hecs_table_2 << [1236.99, 0.060]
        hecs_table_2 << [1320.99, 0.065]
        hecs_table_2 << [1488.99, 0.070]
        hecs_table_2 << [1608.99, 0.075]
        hecs_table_2 << [9999.99, 0.080]
        
        tables[:hecs] = { threshold: hecs_table_1, no_threshold: hecs_table_2 }
                                      
        weekly_amt = convert_to_weekly(amount, freq)
        x_param = weekly_amt.floor + 0.99
        
        tax_free_threshold = threshold ? "threshold" : "no_threshold"
        tax_table_used = tables[:tax][(tax_free_threshold).to_sym]
        tax_params = get_a_and_b(weekly_amt, tax_table_used)
        
        hecs_table_used = tables[:hecs][(tax_free_threshold).to_sym]
        hecs_params = get_a_and_b(weekly_amt, hecs_table_used)
        hecs_amount = hecs ? weekly_amt * hecs_params[:a] : 0
        
        withholding = (tax_params[:a] * x_param) - tax_params[:b] + hecs_amount
        eval "convert_to_#{freq.downcase}(withholding.floor, 'Weekly')"
    end
    
    private
        def get_a_and_b(amount, table)
            ret_hash = {}
            counter = 0
            
            loop do
                ret_hash = { a: table[counter][1], b: table[counter][2] }
                break if amount < table[counter][0]
                counter += 1
            end
            
            ret_hash
        end
end
