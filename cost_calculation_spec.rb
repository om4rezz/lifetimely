require 'rspec'
require_relative 'cost_calculation'

describe CostCalculation do
  context "Daily cost" do
    start_date = Date.new(2019, 10, 1)
    end_date = Date.new(2019, 10, 5)

    ALL_TIME_PERIODS = %w(daily weekly monthly)

    time_period_costs = [
      {
        time_period: ALL_TIME_PERIODS[0], # daily
        cost: 10.0
      },
      {
        time_period: ALL_TIME_PERIODS[1], # weekly
        cost: 70.0
      },
      {
        time_period: ALL_TIME_PERIODS[2], # monthly
        cost: 310.0
      }
    ]

    it "calculate the daily cost for a single period" do
      single_time_period = [
        {
          time_period: ALL_TIME_PERIODS[0], # daily
          cost: 15.0
        }
      ]

      cost_calc = CostCalculation.new

      expect(cost_calc.daily_cost(start_date, end_date, single_time_period).length).to eq(5)
      expect(cost_calc.daily_cost(start_date, end_date, single_time_period)[0][:cost]).to eq(15)

    end

    it "calculate the daily cost for a multiple periods ~ Mixed (Daily, Weekly, Monthly)" do
      cost_calc = CostCalculation.new

      expect(cost_calc.daily_cost(start_date, end_date, time_period_costs).length).to eq(5)
      expect(cost_calc.daily_cost(start_date, end_date, time_period_costs)[0][:date]).to eq(start_date.strftime("%a, %d %b %Y"))
      expect(cost_calc.daily_cost(start_date, end_date, time_period_costs)[4][:date]).to eq(end_date.strftime("%a, %d %b %Y"))
    end

    it "returns an InvalidDatesError when start_date > end_date" do
      invalid_start_date = Date.new(2019, 10, 11)

      cost_calc = CostCalculation.new

      expect{cost_calc.daily_cost(invalid_start_date, end_date, time_period_costs)}.to raise_error(InvalidDatesError)
    end

    it "returns a WrongCostError when negative cost values" do
      negative_time_period_costs = [
        {
          time_period: 'daily',
          cost: 10.0
        },
        {
          time_period: 'annual', # wrong value
          cost: -5.0 # negative value
        },
      ]

      cost_calc = CostCalculation.new

      expect{cost_calc.daily_cost(start_date, end_date, negative_time_period_costs)}.to raise_error(WrongCostError)
    end

    it "returns a WrongTimePeriodValuesError when invalid time period value" do
      wrong_time_period_costs = [
        {
          time_period: 'daily',
          cost: 10.0
        },
        {
          time_period: 'annual', # wrong value
          cost: 5.0 # negative value
        },
      ]

      cost_calc = CostCalculation.new

      expect{cost_calc.daily_cost(start_date, end_date, wrong_time_period_costs)}.to raise_error(WrongTimePeriodValuesError)
    end

  end
end