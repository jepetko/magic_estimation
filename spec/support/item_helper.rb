module ItemHelper

  def assign_items_to_user(names, user)
    Item.where(name: names).each do |item|
      item.assign_to_initial_estimator(user)
    end
  end

end