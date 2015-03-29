module ApplicationHelper

  def users_as_options_array
    arr = []
    User.all.map do |u|
      arr << [u.name, u.id]
    end
    arr
  end

  def percentage(part,total)
    number_to_percentage(part.to_f/total.to_f*100,precision: 0) unless total == 0
  end

  def top_percent_for_value(values, value)
    index = values.sort.index value
    number_to_percentage(100.0-(index.to_f+1.0)/values.count.to_f*100, precision: 0)
  end
end
