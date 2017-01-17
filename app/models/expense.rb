class Expense < ApplicationRecord
    
    def convert_to_fortnightly
        freq = self.frequency
        amt = self.amount
        
        if freq == "Weekly"
            return amt * 2
        elsif freq == "Fortnightly"
            return amt
        elsif freq == "Monthly"
            return (amt * 12)/26
        elsif freq == "Yearly"
            return amt / 26
        else
            return 0
        end
    end
end
