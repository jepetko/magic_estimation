require 'spec_helper'

describe Item do

  before(:all) do
    @admin = User.create(name: 'boss', password: 'boss', password_confirmation: 'boss', role: 'admin')
    @bob = User.create(name: 'bob', password: 'bob', password_confirmation: 'bob', role: 'member')
    @jeff = User.create(name: 'jeff', password: 'jeff', password_confirmation: 'jeff', role: 'member')

    @backlog = Backlog.create(name: 'Backlog', description: 'Backlog including 10 items', creator: @admin)
    10.times { |t| @backlog.items.build(name: "Item #{t+1}", description: 'Lorem ipsum', creator: @admin) }
    @backlog.save!
  end

  context 'from 10 items in total' do

    it 'shows 10 as backlog size' do
      expect(@backlog.items.count).to be(10)
    end

    context 'when 3 items are assigned to bob, 3 items are assigned to jeff' do

      before(:each) do
        assign_items_to_user(['Item 1', 'Item 2', 'Item 3'], @bob)
        assign_items_to_user(['Item 4', 'Item 5', 'Item 6'], @jeff)
      end

      context 'for bob' do

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

      context 'for jeff' do

        it 'shows not estimated=10, already estimated=0' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@jeff).size).to be(10)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@jeff).size).to be(0)
        end

        it 'requires him to estimate 3 issues initially' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @jeff) {|size| size_items_to_be_estimated_initially = size}).to be(true)
          expect(size_items_to_be_estimated_initially).to be(3)
        end
      end

    end

    context 'when bob estimates 2 of the assigned items and jeff does nothing' do

      before(:each) do
        assign_items_to_user(['Item 1', 'Item 2', 'Item 3'], @bob)
        assign_items_to_user(['Item 4', 'Item 5', 'Item 6'], @jeff)
        Item.find_by(name: 'Item 1').estimate(@bob, 50)
        Item.find_by(name: 'Item 2').estimate(@bob, 50)
      end

      context 'for bob' do
        it 'returns 3 assigned items' do
          expect(@bob.items.count).to be(3)
        end

        it 'shows not estimated=8, already estimated=2' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@bob).size).to be(8)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@bob).size).to be(2)
        end

        it 'requires him to estimate 1 issues initially' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @bob) {|size| size_items_to_be_estimated_initially = size}).to be(true)
          expect(size_items_to_be_estimated_initially).to be(1)
        end
      end

      context 'for jeff' do
        it 'returns 3 assigned items' do
          expect(@jeff.items.count).to be(3)
        end

        it 'shows not estimated=10, already estimated=0' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@jeff).size).to be(10)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@jeff).size).to be(0)
        end

        it 'requires him to estimate 3 issues initially and 2 issues as benchmark estimation' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @jeff) {|size| size_items_to_be_estimated_initially = size}).to be(true)
          expect(size_items_to_be_estimated_initially).to be(3)

          size_items_to_be_estimated_next = 0
          expect(Item.any_to_be_estimated_next?(@backlog,@jeff) {|size| size_items_to_be_estimated_next = size} ).to be(true)
          expect(size_items_to_be_estimated_next).to be(2)
        end
      end
    end

    context 'when both, bob and jeff, estimate all 3 assigned items and 2 another items are assigned to jeff for initial estimation' do

      before(:each) do
        assign_items_to_user(['Item 1', 'Item 2', 'Item 3'], @bob)
        assign_items_to_user(['Item 4', 'Item 5', 'Item 6'], @jeff)
        Item.find_by(name: 'Item 1').estimate(@bob, 50)
        Item.find_by(name: 'Item 2').estimate(@bob, 50)
        Item.find_by(name: 'Item 3').estimate(@bob, 50)
        Item.find_by(name: 'Item 4').estimate(@jeff, 100)
        Item.find_by(name: 'Item 5').estimate(@jeff, 100)
        Item.find_by(name: 'Item 6').estimate(@jeff, 100)
        assign_items_to_user(['Item 7', 'Item 8'], @jeff)
      end

      context 'for bob' do
        it 'shows not estimated=7, already estimated=3' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@bob).size).to be(7)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@bob).size).to be(3)
        end

        it 'doesn\'t require him to estimate any issues initially and allows him to estimate 3 issues as benchmark' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @bob) {|size| size_items_to_be_estimated_initially = size}).to be(false)
          expect(size_items_to_be_estimated_initially).to be(0)

          size_items_to_be_estimated_next = 0
          expect(Item.any_to_be_estimated_next?(@backlog, @bob) {|size| size_items_to_be_estimated_next = size}).to be(true)
          expect(size_items_to_be_estimated_next).to be(3)
        end
      end

      context 'for jeff' do
        it 'shows not estimated=7, already estimated=3' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@jeff).size).to be(7)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@jeff).size).to be(3)
        end

        it 'requires him to estimate 2 issues initially and 3 issues as benchmark estimation' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @jeff) {|size| size_items_to_be_estimated_initially = size}).to be(true)
          expect(size_items_to_be_estimated_initially).to be(2)

          size_items_to_be_estimated_next = 0
          expect(Item.any_to_be_estimated_next?(@backlog,@jeff) {|size| size_items_to_be_estimated_next = size} ).to be(true)
          expect(size_items_to_be_estimated_next).to be(3)
        end
      end
    end

    context 'when bob estimates 3 of 4 assigned items initially and 3 as benchmark estimations and jeff estimates all 5 assigned items and 3 as benchmark estimations' do

      before(:each) do
        assign_items_to_user(['Item 1', 'Item 2', 'Item 3'], @bob)
        assign_items_to_user(['Item 4', 'Item 5', 'Item 6'], @jeff)
        Item.find_by(name: 'Item 1').estimate(@bob, 50)
        Item.find_by(name: 'Item 2').estimate(@bob, 50)
        Item.find_by(name: 'Item 3').estimate(@bob, 50)
        Item.find_by(name: 'Item 4').estimate(@jeff, 100)
        Item.find_by(name: 'Item 5').estimate(@jeff, 100)
        Item.find_by(name: 'Item 6').estimate(@jeff, 100)
        assign_items_to_user(['Item 7', 'Item 8'], @jeff)
        assign_items_to_user(['Item 9'], @bob)
        Item.find_by(name: 'Item 4').estimate(@bob, 3)
        Item.find_by(name: 'Item 5').estimate(@bob, 3)
        Item.find_by(name: 'Item 6').estimate(@bob, 3)
        Item.find_by(name: 'Item 7').estimate(@jeff, 100)
        Item.find_by(name: 'Item 8').estimate(@jeff, 100)
        Item.find_by(name: 'Item 1').estimate(@jeff, 8)
        Item.find_by(name: 'Item 2').estimate(@jeff, 8)
        Item.find_by(name: 'Item 3').estimate(@jeff, 8)
      end

      context 'for bob' do
        it 'shows not estimated=4, already estimated=6' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@bob).size).to be(4)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@bob).size).to be(6)
        end

        it 'requires him to estimate 1 issue initially and allows him to estimate 2 issues as benchmark' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @bob) {|size| size_items_to_be_estimated_initially = size}).to be(true)
          expect(size_items_to_be_estimated_initially).to be(1)

          size_items_to_be_estimated_next = 0
          expect(Item.any_to_be_estimated_next?(@backlog, @bob) {|size| size_items_to_be_estimated_next = size}).to be(true)
          expect(size_items_to_be_estimated_next).to be(2)
        end
      end

      context 'for jeff' do
        it 'shows not estimated=2, already estimated=8' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@jeff).size).to be(2)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@jeff).size).to be(8)
        end

        it 'doesn\'t require him to estimate any issues' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @jeff) {|size| size_items_to_be_estimated_initially = size}).to be(false)
          expect(size_items_to_be_estimated_initially).to be(0)

          size_items_to_be_estimated_next = 0
          expect(Item.any_to_be_estimated_next?(@backlog,@jeff) {|size| size_items_to_be_estimated_next = size} ).to be(false)
          expect(size_items_to_be_estimated_next).to be(0)
        end
      end
    end

    context 'when bob estimates 4 assigned items initially and 3 as benchmark estimations and jeff estimates all 5 assigned items and 4 as benchmark estimations \
             and bob gets assigned a new issue which remains without estimation' do

      before(:each) do
        assign_items_to_user(['Item 1', 'Item 2', 'Item 3'], @bob)
        assign_items_to_user(['Item 4', 'Item 5', 'Item 6'], @jeff)
        Item.find_by(name: 'Item 1').estimate(@bob, 50)
        Item.find_by(name: 'Item 2').estimate(@bob, 50)
        Item.find_by(name: 'Item 3').estimate(@bob, 50)
        Item.find_by(name: 'Item 4').estimate(@jeff, 100)
        Item.find_by(name: 'Item 5').estimate(@jeff, 100)
        Item.find_by(name: 'Item 6').estimate(@jeff, 100)
        assign_items_to_user(['Item 7', 'Item 8'], @jeff)
        assign_items_to_user(['Item 9'], @bob)
        Item.find_by(name: 'Item 4').estimate(@bob, 3)
        Item.find_by(name: 'Item 5').estimate(@bob, 3)
        Item.find_by(name: 'Item 6').estimate(@bob, 3)
        Item.find_by(name: 'Item 7').estimate(@jeff, 100)
        Item.find_by(name: 'Item 8').estimate(@jeff, 100)
        Item.find_by(name: 'Item 1').estimate(@jeff, 8)
        Item.find_by(name: 'Item 2').estimate(@jeff, 8)
        Item.find_by(name: 'Item 3').estimate(@jeff, 8)

        Item.find_by(name: 'Item 7').estimate(@bob, 3)
        Item.find_by(name: 'Item 8').estimate(@bob, 3)
        Item.find_by(name: 'Item 9').estimate(@bob, 50)
        Item.find_by(name: 'Item 9').estimate(@jeff, 8)
        assign_items_to_user(['Item 10'], @bob)
      end

      context 'for bob' do
        it 'shows not estimated=1, already estimated=9' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@bob).size).to be(1)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@bob).size).to be(9)
        end

        it 'requires him to estimate 1 issue initially and doesn\'t allow him to estimate any items as benchmark' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @bob) {|size| size_items_to_be_estimated_initially = size}).to be(true)
          expect(size_items_to_be_estimated_initially).to be(1)

          size_items_to_be_estimated_next = 0
          expect(Item.any_to_be_estimated_next?(@backlog, @bob) {|size| size_items_to_be_estimated_next = size}).to be(false)
          expect(size_items_to_be_estimated_next).to be(0)
        end
      end

      context 'for jeff' do
        it 'shows not estimated=1, already estimated=9' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@jeff).size).to be(1)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@jeff).size).to be(9)
        end

        it 'doesn\'t require him to estimate any issues' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @jeff) {|size| size_items_to_be_estimated_initially = size}).to be(false)
          expect(size_items_to_be_estimated_initially).to be(0)

          size_items_to_be_estimated_next = 0
          expect(Item.any_to_be_estimated_next?(@backlog,@jeff) {|size| size_items_to_be_estimated_next = size} ).to be(false)
          expect(size_items_to_be_estimated_next).to be(0)
        end
      end
    end

    context 'when both, bob and jeff, estimate all assigned issues (either initially or as benchmark estimator)' do

      before(:each) do
        assign_items_to_user(['Item 1', 'Item 2', 'Item 3'], @bob)
        assign_items_to_user(['Item 4', 'Item 5', 'Item 6'], @jeff)
        Item.find_by(name: 'Item 1').estimate(@bob, 50)
        Item.find_by(name: 'Item 2').estimate(@bob, 50)
        Item.find_by(name: 'Item 3').estimate(@bob, 50)
        Item.find_by(name: 'Item 4').estimate(@jeff, 100)
        Item.find_by(name: 'Item 5').estimate(@jeff, 100)
        Item.find_by(name: 'Item 6').estimate(@jeff, 100)
        assign_items_to_user(['Item 7', 'Item 8'], @jeff)
        assign_items_to_user(['Item 9'], @bob)
        Item.find_by(name: 'Item 4').estimate(@bob, 3)
        Item.find_by(name: 'Item 5').estimate(@bob, 3)
        Item.find_by(name: 'Item 6').estimate(@bob, 3)
        Item.find_by(name: 'Item 7').estimate(@jeff, 100)
        Item.find_by(name: 'Item 8').estimate(@jeff, 100)
        Item.find_by(name: 'Item 1').estimate(@jeff, 8)
        Item.find_by(name: 'Item 2').estimate(@jeff, 8)
        Item.find_by(name: 'Item 3').estimate(@jeff, 8)

        Item.find_by(name: 'Item 7').estimate(@bob, 3)
        Item.find_by(name: 'Item 8').estimate(@bob, 3)
        Item.find_by(name: 'Item 9').estimate(@bob, 50)
        Item.find_by(name: 'Item 9').estimate(@jeff, 8)
        assign_items_to_user(['Item 10'], @bob)

        Item.find_by(name: 'Item 10').estimate(@bob, 50)
        Item.find_by(name: 'Item 10').estimate(@jeff, 8)
      end

      context 'for bob' do
        it 'shows not estimated=0, already estimated=10' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@bob).size).to be(0)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@bob).size).to be(10)
        end

        it 'doesn\'t require him or allow to estimate any items' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @bob) {|size| size_items_to_be_estimated_initially = size}).to be(false)
          expect(size_items_to_be_estimated_initially).to be(0)

          size_items_to_be_estimated_next = 0
          expect(Item.any_to_be_estimated_next?(@backlog, @bob) {|size| size_items_to_be_estimated_next = size}).to be(false)
          expect(size_items_to_be_estimated_next).to be(0)
        end
      end

      context 'for jeff' do
        it 'shows not estimated=0, already estimated=10' do
          expect(Item.for_backlog_and_estimator_not_estimated_yet(@backlog,@jeff).size).to be(0)
          expect(Item.for_backlog_and_estimator_already_estimated(@backlog,@jeff).size).to be(10)
        end

        it 'doesn\'t require him or allow to estimate any issues' do
          size_items_to_be_estimated_initially = 0
          expect(Item.any_to_be_estimated_initially?(@backlog, @jeff) {|size| size_items_to_be_estimated_initially = size}).to be(false)
          expect(size_items_to_be_estimated_initially).to be(0)

          size_items_to_be_estimated_next = 0
          expect(Item.any_to_be_estimated_next?(@backlog,@jeff) {|size| size_items_to_be_estimated_next = size} ).to be(false)
          expect(size_items_to_be_estimated_next).to be(0)
        end
      end
    end
  end

end

