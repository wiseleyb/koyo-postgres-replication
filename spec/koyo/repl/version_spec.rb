# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Koyo::Repl, type: :service do
  it 'works' do
    expect(Koyo::Repl::VERSION).to eq('7.0.0')
  end
end
