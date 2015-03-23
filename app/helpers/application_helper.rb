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
end
