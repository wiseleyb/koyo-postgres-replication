# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  # Smoke test
  it 'works' do
    name = "Test #{Time.now}"
    u = User.create(name:)
    expect(User.find(u.id).name).to eq(name)
  end

  # Very basic spec example for testing koyo:repl
  context 'basic koyo:repl test' do
    before do
      expect(Koyo::Repl::Database.replication_slot_exists?).to be_truthy
    end

    context 'running server' do
      let(:user) { User.new }

      before do
        # clean out data that might already be in the slot
        Koyo::Repl::PostgresServer.new.check

        # test that replication calls the call backs (processes data)
        expect(User).to receive(:handle_replication)
        expect(Koyo::Repl::EventHandlerService).to \
          receive(:koyo_handle_all_replication)
        expect(Koyo::Repl::EventHandlerService).to \
          receive(:koyo_log_event).at_least(:once)
      end

      it 'works' do
        user.name = "test #{Time.now}"
        user.save!

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

    context 'finds models to be notified' do
      let(:tables) do
        Koyo::Repl::PostgresServer.tables_that_handle_koyo_replication
      end

      it 'works' do
        res = {
          'user_interests_non_rails' => 'UserInterestsNonRail',
          'users' => 'User'
        }
        expect(tables).to eq(res)
        expect(Koyo::Repl::PostgresServer.new.tables).to eq(res)
      end
    end
  end
end
