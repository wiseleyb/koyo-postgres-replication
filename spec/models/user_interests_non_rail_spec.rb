# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserInterestsNonRail, type: :model do
  # Smoke test
  it 'works' do
    name = "Test #{Time.now}"
    u = User.create(name:)
    name = 'Space Aliens'
    i = Interest.create(name:)
    UserInterestsNonRail.create(user_id: u.id, interest_id: i.id)
    expect(UserInterestsNonRail.where(user_id: u.id,
                                      interest_id: i.id).count).to eq(1)
  end

  # Very basic spec example for testing koyo:repl
  context 'basic koyo:repl test' do
    before do
      expect(Koyo::Repl::Database.replication_slot_exists?).to be_truthy
    end

    context 'running server' do
      before do
        User.create(name: "User #{Time.now}")
        Interest.create(name: "Interest #{Time.now}")
        UserInterestsNonRail.destroy_all

        # clean out data that might already be in the slot
        Koyo::Repl::PostgresServer.new.check

        # test that replication calls the call backs (processes data)
        expect(UserInterestsNonRail).to receive(:handle_replication)
        expect(Koyo::Repl::EventHandlerService).to \
          receive(:koyo_handle_all_replication)
        expect(Koyo::Repl::EventHandlerService).to \
          receive(:koyo_log_event).at_least(:once)
      end

      it 'works' do
        UserInterestsNonRail.where(user_id: User.first.id,
                                   interest_id: Interest.first.id)
                            .first_or_create

        # You can debug things with code like this
        # See all replication slots
        #   slots = Koyo::Repl::Database.replication_slots
        # See replication slot for this database
        #   slot = Koyo::Repl::Database.replication_slot
        # Peek at what's in the current replication slot
        #   res = Koyo::Repl::Database.peek_slot
        Koyo::Repl::PostgresServer.new.check
      end
    end
  end
end
