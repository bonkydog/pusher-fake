module PusherFake
  class Webhook
    class << self
      def trigger(name, data = {})
        payload = MultiJson.dump({
          events:  [data.merge(name: name)],
          time_ms: Time.now.to_i
        })

        PusherFake.configuration.webhooks.each do |url|
          http = EventMachine::HttpRequest.new(url)
          http.post(body: payload, head: headers_for(payload))
        end
      end

      private

      def headers_for(payload)
        { "Content-Type"       => "application/json",
          "X-Pusher-Key"       => PusherFake.configuration.key,
          "X-Pusher-Signature" => signature_for(payload)
        }
      end

      def signature_for(payload)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, PusherFake.configuration.secret, payload)
      end
    end
  end
end
