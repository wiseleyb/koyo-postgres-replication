# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interest, type: :model do
  # Smoke test
  it 'works' do
    name = 'Space Aliens'
    i = Interest.create(name:)
    expect(Interest.find(i.id).name).to eq(name)
  end
end
