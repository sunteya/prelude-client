class Client
  include Singleton
  include HTTParty
  base_uri Project.settings.endpoint
  headers "X-Access-Token" => Project.settings.access_token
  
  def users!
    response = self.class.get("/api/v1/users.json")
    if response.code == 200
      response.as_json
    else
      raise ResponseError.new(response)
    end
  end

  def update_traffic(traffic)
    params = {
      traffic: {
        upcode: traffic.id.to_s,
        start_at: traffic.start_at,
        period: 'immediate',
        remote_ip: traffic.remote_ip,
        incoming_bytes: traffic.incoming_bytes,
        outgoing_bytes: traffic.outgoing_bytes
      }
    }
    response = self.class.post("/api/v1/users/#{traffic.user.upcode}/traffics.json", body: params)
    if response.code == 201 || response.as_json["error_code"]
      response.as_json
    else
      raise ResponseError.new(response)
    end
  end

  class ResponseError < RuntimeError
    attr_accessor :code

    def initialize(response)
      super(response.as_json["message"] || response.as_json["error"] || response_to_s)
      self.code = response.code
    end
  end
end
