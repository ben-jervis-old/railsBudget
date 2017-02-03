class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  
  include ExpensesHelper
  
  # GET /expenses
  # GET /expenses.json
  def index
    @expenses = Expense.all.sort { |a, b| b.convert_to_fortnightly <=> a.convert_to_fortnightly }
    @new_expense = Expense.new
    @sum_expenses = sum_fortnightly_amounts(@expenses)
    @frequencies = freq_list
    
    respond_to do |format|
      format.html
      format.csv { send_data @expenses.to_csv, filename: "ExpenseList#{Time.now.in_time_zone("Sydney").strftime("%H%M%S_%d%m%Y")}.csv" }
    end
  end
    

  # GET /expenses/1
  # GET /expenses/1.json
  def show
    @frequencies = freq_list
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
    @frequencies = freq_list
  end

  # GET /expenses/1/edit
  def edit
    @frequencies = freq_list
  end

  # POST /expenses
  # POST /expenses.json
  def create
    @expense = Expense.new(expense_params)

    respond_to do |format|
      if @expense.save
        format.html { redirect_to root_url, notice: 'Expense was successfully created.' }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenses/1
  # PATCH/PUT /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to root_url, notice: 'Expense was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1
  # DELETE /expenses/1.json
  def destroy
    @expense.destroy
    respond_to do |format|
      format.html { redirect_to expenses_url, notice: 'Expense was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expense_params
      params.require(:expense).permit(:title, :amount, :frequency)
    end
    
    def sum_fortnightly_amounts(expenses)
        sum_val = 0.0
        expenses.each { |exp| sum_val += exp.convert_to_fortnightly }
        return sum_val
    end
end
