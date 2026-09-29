# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicUrl do
  let(:path) { Rails.root.join('tmp/test_public_url') }

  before { stub_const('PublicUrl::PATH', path) }
  after { FileUtils.rm_f(path) }

  it 'reads the link bin/launch saved' do
    File.write(path, "https://abc123.ngrok-free.app\n")

    expect(PublicUrl.current).to eq('https://abc123.ngrok-free.app')
  end

  it 'is nil when nothing was saved' do
    expect(PublicUrl.current).to be_nil
  end

  it 'builds a link from the saved base, falling back to the request' do
    File.write(path, 'https://abc123.ngrok-free.app')

    expect(PublicUrl.for('/join/new?code=ABCD', fallback: 'http://localhost:3000'))
      .to eq('https://abc123.ngrok-free.app/join/new?code=ABCD')

    FileUtils.rm_f(path)
    expect(PublicUrl.for('/join/new?code=ABCD', fallback: 'http://localhost:3000'))
      .to eq('http://localhost:3000/join/new?code=ABCD')
  end
end
