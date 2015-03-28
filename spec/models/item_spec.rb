require 'spec_helper'

describe Item do

  before(:all) do
    @admin = User.create(name: 'boss', password: 'boss', password_confirmation: 'boss', role: 'admin')
    @bob = User.create(name: 'bob', password: 'bob', password_confirmation: 'bob', role: 'member')
    @jeff = User.create(name: 'jeff', password: 'jeff', password_confirmation: 'jeff', role: 'member')

    @backlog = Backlog.create(name: 'Backlog', description: 'Backlog including 10 items', creator: @admin)
    10.times { |t| @backlog.items.build(name: "Item #{t}", description: 'Lorem ipsum', creator: @admin) }
    @backlog.save!
  end

  context 'from 10 items in total' do

    it 'shows 10 as backlog size' do
      expect(@backlog.items.count).to be(10)
    end

    context 'when 3 items are assigned to bob, 3 items are assigned to jeff' do

      before(:all) do
        assign_items_to_user(['Item 1', 'Item 2', 'Item 3'], @bob)
        assign_items_to_user(['Item 4', 'Item 5', 'Item 6'], @jeff)
      end

      context 'for bob' do

        it 'returns 3 assigned items' do
          expect(@bob.items.count).to be(3)
        end

        it 'shows not estimated=10, already estimated=0' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@bob).size).to be(10)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@bob).size).to be(0)
        end

        it 'requires him to estimate 3 issues initially' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @bob) {|size| size_items_to_be_estimated_initially = size}).to be(true)
          expect(size_items_to_be_estimated_initially).to be(3)
        end

      end
    end
  end

end

