class FindADataCenter
  class << self
    def get(url)
      response = Net::HTTP.get(URI.parse("#{remote_url}#{url}.json?api_key=#{api_key}"))
      begin
        JSON.parse(response)
      rescue JSON::ParserError
      end
    end

    def post(url, params)
      post_params = {'api_key' => api_key}
      params.delete_if{|key, value| value.blank? || key =~ /^(controller|action|id)$/ || key.downcase == value.downcase }
      post_params.merge!(params)
      begin
        response = Net::HTTP.post_form(URI.parse("#{remote_url}#{url}.json"), post_params)
        if response.is_a?(Net::HTTPOK)
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError
          end
        end
      rescue Errno::ECONNREFUSED
        {}
      end
    end

    private
    def api_key
      # Production
      'f4f8149350ec21ae9be3f3d9911d2cceac971f68'
      # Development
      # 'f4f8149350ec21ae9be3f3d9911d2cceac971f68'
    end

    def remote_url
      # Production
      'http://www.findadatacenter.com/'
      # Development
      # 'http://127.0.0.1:3001/'
    end
  end
end