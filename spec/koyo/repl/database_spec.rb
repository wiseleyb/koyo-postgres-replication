# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Koyo::Repl::Database, type: :service do
  let(:user) { build(:user) }
  let(:subject) { Koyo::Repl::Database }

  # this clears any garbage left over in the replication slot
  before do
    subject.read_slot!
  end

  context :read_slot! do
    it 'works with no data' do
      res = subject.read_slot!
      expect(res.first).to be_nil
    end

    it 'worsk with data' do
      user.save
      res = subject.read_slot!
      json = JSON.parse(res.first['data'])
      expect(json['change'].first['table']).to eq('users')
      # calling again - shouldn't get the same data
      res = subject.read_slot!
      expect(res.first).to be_nil
    end
  end

  context :peek_slot do
    it 'works with no data' do
      res = subject.peek_slot
      expect(res.first).to be_nil
    end

    it 'works with data' do
      user.save
      res = subject.peek_slot
      json = JSON.parse(res.first['data'])
      expect(json['change'].first['table']).to eq('users')
      # calling again - should get same data
      res = subject.peek_slot
      json = JSON.parse(res.first['data'])
      expect(json['change'].first['table']).to eq('users')
    end
  end

  context :replication_slot_count do
    it 'works' do
      expect(subject.replication_slot_count).to eq(0)
      user.save
      expect(subject.replication_slot_count).to eq(1)
      create(:user)
      expect(subject.replication_slot_count).to eq(2)
    end
  end

  context :replication_slot_exists? do
    it 'works' do
      expect(subject.replication_slot_exists?).to be_truthy

      # drop slot
      subject.delete_replication_slot!
      expect(subject.replication_slot_exists?).to be_falsey

      # recreate slot
      subject.create_replication_slot!
      expect(subject.replication_slot_exists?).to be_truthy
    end
  end

  context :wal_level do
    it 'works' do
      expect(subject.wal_level).to eq('logical')
    end
  end
end
