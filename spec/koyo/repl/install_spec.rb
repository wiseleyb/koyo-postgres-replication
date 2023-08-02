# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Koyo::Repl::Install, type: :service do
  # kind of tricky to test file copies on an app that's running
  # so this is pretty rubbish/smoke-test level
  it 'works' do
    expect_any_instance_of(Koyo::Repl::Install).to \
      receive(:copy).at_least(3).times
    Koyo::Repl::Install.copy!
  end
end
