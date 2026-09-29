# frozen_string_literal: true

# The link players can actually reach. bin/launch writes the current ngrok address here each time
# it starts, so the lobby QR code points at the tunnel even when the host screen is on localhost.
class PublicUrl
  PATH = Rails.root.join('tmp/public_url')

  def self.current
    PATH.exist? ? PATH.read.strip.presence : nil
  end

  def self.for(path, fallback:)
    "#{current || fallback}#{path}"
  end
end
