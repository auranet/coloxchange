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
            response = JSON.parse(response.body)
            if response['error']
              RAILS_DEFAULT_LOGGER.warn("\nFindADataCenter API error: #{response['error']}\n\n")
            end
            response
          rescue JSON::ParserError
          end
        end
      rescue Errno::ECONNREFUSED
        {}
      end
    end

    def remote_url
      # if RAILS_ENV == 'production'
        # Production
        'http://www.findadatacenter.com/'
      # else
        # Development
        # 'http://127.0.0.1:3001/'
      # end
    end

    private
    def api_key
      # if RAILS_ENV == 'production'
        # Production
        'f4f8149350ec21ae9be3f3d9911d2cceac971f68'
      # else
        # Development
        # '74d8c284ad91ad823a327e18787cf9fbebb5a925'
      # end
    end
  end
end