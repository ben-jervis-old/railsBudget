class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  @frequencies = ["Weekly", "Fortnightly", "Monthly", "Yearly"]

  # GET /expenses
  # GET /expenses.json
  def index
    @expenses = Expense.all
    @sum_expenses = sum_fortnightly_amounts(@expenses)
  end

  # GET /expenses/1
  # GET /expenses/1.json
  def show
    @frequencies = ["Weekly", "Fortnightly", "Monthly", "Yearly"]
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
    @frequencies = ["Weekly", "Fortnightly", "Monthly", "Yearly"]
  end

  # GET /expenses/1/edit
  def edit
    @frequencies = ["Weekly", "Fortnightly", "Monthly", "Yearly"]
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
        format.html { redirect_to @expense, notice: 'Expense was successfully updated.' }
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
