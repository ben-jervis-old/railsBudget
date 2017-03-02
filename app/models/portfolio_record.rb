class PortfolioRecord < ApplicationRecord
    
    def init_vals(date, stock)
        self.date = date
        stock.each do |k, v|
            #v.each do |key, val|
                self.send("#{k}=", v)
            #end
        end
    end
        
end
