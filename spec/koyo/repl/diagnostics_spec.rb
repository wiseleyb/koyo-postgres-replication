# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Koyo::Repl::Diagnostics, type: :service do
  # TODO: flush this out more - just a smoke test
  it 'works' do
    str = Koyo::Repl::Diagnostics.new.rake_info
    expect(str).to_not be_blank
    expect(str).to_not include('Error')
  end
end
