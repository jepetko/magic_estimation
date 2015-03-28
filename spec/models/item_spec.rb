require 'spec_helper'

describe Item do

  before(:all) do
    @admin = User.new(name: 'boss', password: 'boss', password_confirmation: 'boss', role: 'admin')
    @bob = User.new(name: 'bob', password: 'bob', password_confirmation: 'bob', role: 'member')
    @jeff = User.new(name: 'jeff', password: 'jeff', password_confirmation: 'jeff', role: 'member')

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

      end

      context 'for bob' do
        it 'shows not estimated=10, already estimated=0' do

          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@bob).size).to be(3)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@bob).size).to be(3)

        end

        it 'requires him to estimate 3 issues initially' do
          pending
        end

      end
    end
  end

end

