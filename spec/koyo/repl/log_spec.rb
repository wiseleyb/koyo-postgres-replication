# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Koyo::Repl::Log, type: :service do
  # simple smoke test
  it 'works' do
    expect(KoyoReplHandler).to receive(:koyo_log_event).at_least(5)
    klass = Koyo::Repl::PostgresServer
    klass.log_repl_debug('test')
    klass.log_repl_info('test')
    klass.log_repl_warn('test')
    klass.log_repl_error('test')
    klass.log_repl_fatal('test')
  end
end
