module ApplicationHelper

  def users_as_options_array
    arr = []
    User.all.map do |u|
      arr << [u.name, u.id]
    end
    arr
  end
end
