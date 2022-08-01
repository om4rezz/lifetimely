require "date"
require_relative "exceptions/invalid_dates_error"
require_relative "exceptions/wrong_cost_error"
require_relative "exceptions/wrong_time_period_values_error"

ALL_TIME_PERIODS = %w(daily weekly monthly)

class CostCalculation
  def correct_time_interval?(start_date, end_date)
    start_date <= end_date
  end

  def is_valid_cost_values?(time_period_costs)
    cost_values = time_period_costs.map{ |record| record[:cost] }
    cost_values.select { |v| v < 0 }.length == 0
  end

  def is_valid_time_period_values?(time_period_costs)
    time_period_values = time_period_costs.map{ |record| record[:time_period] }
    time_period_values.select { |v| !ALL_TIME_PERIODS.include?(v) }.length == 0
  end

  def daily_cost(start_date, end_date, time_period_costs)
    raise InvalidDatesError.new("End date can not be before start date") unless correct_time_interval?(start_date, end_date)
    raise WrongCostError.new("Cost values can not be negative") unless is_valid_cost_values?(time_period_costs)
    raise WrongTimePeriodValuesError.new("Time period value options are (daily, weekly or monthly)") unless is_valid_time_period_values?(time_period_costs)

    daily_cost_payload = (start_date..end_date).map do |day|
      costs = time_period_costs.map do |record|
        case record[:time_period]
        when ALL_TIME_PERIODS[0] then record[:cost]
        when ALL_TIME_PERIODS[1] then record[:cost] / 7
        when ALL_TIME_PERIODS[2] then record[:cost] / Date.new(day.year, day.month, -1).day
        else 0
        end
      end

      {
        :date => day.strftime("%a, %d %b %Y"),
        :cost => costs.sum
      }
    end

    daily_cost_payload
  end
end
