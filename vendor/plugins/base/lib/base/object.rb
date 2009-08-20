module Base
  module ObjectExtensions
    def admin_email
      Base.admin_email
    end

    def currency
      Base.currency
    end

    def currency_symbol
      Base.currency_symbol
    end

    def domain
      Base.domain
    end

    def domain_short
      Base.domain_short
    end

    def email_support
      Base.email_support
    end

    def login_url
      Base.urls["login"]
    end

    def site_name
      Configuration.site_name
    end

    def site_name_legal
      Configuration.site_name_legal
    end

    def site_name_clean
      Configuration.site_name_clean
    end

    def site_tag_line
      Configuration.site_tag_line
    end
  end
end