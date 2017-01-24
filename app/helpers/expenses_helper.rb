module ExpensesHelper
    def de_adverb(str)
        str.chomp('ly')
    end
    
    def freq_list
        %w(Weekly Fortnightly Monthly Yearly)
    end
end
