# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Koyo::Repl::DataRow, type: :service do
  # simple smoke test
  it 'works' do
    u = create(:user)
    sql_results = Koyo::Repl::Utils.read_slot!
    sql_res = sql_results.first
    row = Koyo::Repl::Data.new(sql_res).rows.first
    expect(row.kind).to eq('insert')
    expect(row.table).to eq('users')
    expect(row.values.first).to eq(u.id)
    expect(row.values.second).to eq(u.name)
  end
end
