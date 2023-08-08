# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Koyo::Repl::Data, type: :service do
  # simple smoke test
  it 'works' do
    create(:user)
    sql_results = Koyo::Repl::Database.read_slot!
    sql_res = sql_results.first
    data = Koyo::Repl::Data.new(sql_res)
    expect(data.rows.size).to eq(1)
  end
end
