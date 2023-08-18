# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Koyo::Repl, type: :service do
  it 'works' do
    expect(Koyo::Repl::VERSION).to eq('0.1.2.pre')
  end
end
