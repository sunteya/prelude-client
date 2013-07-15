class Client
  include Singleton
  include HTTParty
  base_uri Project.settings.endpoint
  headers "X-Access-Token" => Project.settings.access_token
  
  def users
    response = self.class.get("/api/v1/users.json")
    if response.code == 200
      response.as_json['users']
    else
      raise ResponseError.new(response)
    end
  end

  class ResponseError < RuntimeError
    attr_accessor :code

    def initialize(response)
      super(response.as_json["message"] || response_to_s)
      self.code = response.code
    end
  end
end
