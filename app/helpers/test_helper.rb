module TestHelper
    
    def read_in_market_file(filename)
        
        infile = File.new(filename, 'r')
        
        output_hash = {}
        
        output_hash[:date] = DateTime.parse(infile.gets.split(", ")[1])
        output_hash[:stocks] = {}
        
        while(line = infile.gets)
            first_part = (line.split())[0]
            if first_part.to_s.length == 3
                parts = line.chomp.gsub(/ {2,}/, "\t").split("\t")
                code = parts[0].to_sym
                if output_hash[:stocks].has_key?(code)
                    output_hash[:stocks][code][:quantity] += parts[2].to_i
                    output_hash[:stocks][code][:value] += parts[4].to_f
                else
                    output_hash[:stocks][code] = {  code: parts[0],
                                                name: parts[1],
                                                quantity: parts[2].to_i,
                                                price: parts[3].to_f,
                                                value: parts[4].to_f }
                end
            end
        end
        
        output_hash
        
    end
    
    def output_sums(start_date, end_date, code = nil)
        values = []
        
        start_date = Date.parse(start_date) if start_date.class == 'String'
        end_date = Date.parse(end_date) if end_date.class == 'String'
        
        date_range = (start_date)..(end_date)
        date_range.each do |date|
            sum = 0.0
            if code == nil
                records = PortfolioRecord.where(date: date)
            else
                records = PortfolioRecord.where(date: date, code: code)
            end
            puts "Count: #{records.count}"
            records.each do |r|
                sum += r.value.to_f
            end
            
            values << [date, helper.number_to_currency(sum)] unless sum == 0.0
        end
        values
    end
    
    def save_hash_to_record(result_hash)
        result_hash[:stocks].each do |k, v|
            record = PortfolioRecord.new
            record.init_vals(result_hash[:date], v)
            record.save
        end
    end
    
    def oldest_date
        PortfolioRecord.order(:date).limit(1).pluck(:date)[0]
    end
    
    def newest_date
        PortfolioRecord.order(date: :desc).limit(1).pluck(:date)[0]
    end
    
    def export_to_file(code = nil)
        filename = "Output_" + Time.now.strftime("%H%M%S%d%m%Y") + ".txt"
        outfile = File.new(filename, 'w')
        values = output_sums(oldest_date, newest_date, code)
        values.each do |v|
            outfile << "#{v[0]}\t#{v[1]}\n"
        end
        
        outfile.close
    end

end