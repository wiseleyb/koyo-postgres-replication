# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Koyo::Repl, type: :service do
  it 'works' do
    expect(Koyo::Repl::VERSION).to eq('0.1.5.pre')
  end
end
