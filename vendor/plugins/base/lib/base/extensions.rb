require "digest"
require "digest/sha1"
module Base
  module Extensions
    module ArrayExtension
      def average(method = nil)
        self.inject(0){|sum,value| sum + (method ? value.send(method) : value)} / self.size
      end

      def pad(length,object)
        while self.size < length
          self.push(object)
        end
        self
      end

      def total(method = nil)
        copy = Array.new(self)
        copy.inject(0) {|total,obj| (method ? obj.send(method) : obj) + total}
      end

      def to_csv(options = {})
        String(self.collect {|i| options[:method] ? i.send(options[:method]) : i }.join(","))
      end

      def to_ul(method = nil,options = {})
        options = {:url => nil,:ul_opts => {},:li_opts => {},:id => nil}.update(options)
        ul = "<ul#{options[:ul_opts].to_html}>"
        self.each do |item|
          label = method ? item.send(method) : item
          label = "<a href=\"#{options[:url]}#{item.send(options[:id]) if options[:id]}\">#{label}</a>" if options[:url]
          ul << "<li#{options[:li_opts].to_html}>#{label}</li>"
        end
        "#{ul}</ul>"
      end

      def without(*args)
        copy = Array.new(self)
        args = args.first if args.first.is_a?(Array) && args.size == 1
        for arg in args
          copy.delete(arg)
        end
        copy
      end
    end

    module DateExtension
      def pretty
        "#{self.strftime("%A, %B")} #{self.strftime("%d").gsub(/^0/,"")}, #{self.strftime("%Y")}"
      end

      def pretty_short
        self.strftime("%m/%d/%y").gsub(/^0(\d)/,'\1').gsub(/\/0(\d)\//,'/\1/')
      end
    end

    module FileExtension
      def mkdir_with_date(path,mode=0777)
        begin
          path = File.expand_path(path)
          today = Date.today
          [today.year,today.month,today.day].each do |i|
            path << "/#{i}"
            Dir.mkdir(path,mode) unless File.exists?(path)
          end
          path
        rescue
          false
        end
      end

      def safe_path(path)
        i = 1
        ext = File.extname(path)
        root = "#{File.dirname(path)}/#{File.basename(path,ext)}"
        while File.exists?(path)
          path = "#{root}-#{i}#{ext}"
          i += 1
        end
        return path
      end
    end

    module HashExtension
      def to_html
        html = ''
        self.each_key {|key| html << ' ' + key.to_s + '="' + self[key].to_s + '"'}
        html
      end

      def without(*keys)
        copy = self.clone
        keys = keys.last if keys.last.is_a?(Array)
        for key in keys
          copy.delete(key)
        end
        copy
      end
    end

    module NumericExtension
      def as_short_time
        days,hours,minutes = self.get_time_units
        "#{"#{days}:" if days > 0}#{0 if hours < 10 && days > 0}#{hours}:#{0 if minutes < 10}#{minutes}"
      end

      def as_time
        days,hours,minutes = self.get_time_units
        str = []
        str.push("#{days} day#{"s" unless days == 1}") if days > 0
        str.push("#{hours} hour#{"s" unless hours == 1}") if hours > 0
        str.push("#{minutes} minute#{"s" unless minutes == 1}") if minutes > 0
        str.join(", ")
      end

      def decimalize
        format("%.2f",self)
      end

      def get_time_units
        days = (self/86400).to_i
        hours = ((self - days*86400)/3600).to_i
        minutes = (self - hours*3600).to_i/60 % 60
        [days,hours,minutes]
      end

      def pretty
        Integer(self).to_s.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse
      end
    end

    module StringExtension
      def clean(options = {})
        options = {:except => nil}.update(options)
        str = self.gsub('"',"'")
        if options[:except]
          str.gsub(Regexp.new("<[^(#{options[:except].join("|")}|\\/#{options[:except].join("|\\/")})]+>"),"")
        else
          str.gsub(/<[^>]+>/,"")
        end
      end

      def encode
        self.gsub(/([\\,;\n])/){$1 == "\n" ? '\\\n' : "\\"+$1}
      end

      def encrypt
        Digest::SHA1.hexdigest(self)
      end

      def paragraphize(paragraphs = 1,split = /(<br.*>)+/i)
        brexp = split.is_a?(Regexp) ? split : /#{split}/i
        return self if self !~ brexp
        paragraph_array = []
        self.split(brexp).each_with_index do |paragraph,index|
          break if paragraph_array.size == paragraphs
          if size = brexp.match(paragraph)
            @size = size
          elsif !paragraph.strip.blank?
            paragraph_array.push(paragraph)
          end
        end
        paragraph_array.join("<br />"*(@size ? @size.size : 2))
      end

      def possessive
        "#{self}'#{self.reverse[0,1].downcase == 's' ? '' : 's'}"
      end

      def shorten(length = 150)
        trim = self.gsub(/<(.*?)>/,'')
        trim[0,length] == trim ? trim : (trim[0,length].rindex(/\b\W/) ? trim[0,trim[0,length].rindex(/\b\W/)].strip : trim[0,length].rindex(" ") ? trim[0,trim[0,length].rindex(" ")] : trim[0,length]).strip + "..."
      end

      def without(replace)
        self.gsub(replace,"")
      end
    end

    module TimeExtension
      def ago_s
        now = Time.now
        seconds = now - self.to_time
        days = now.day - self.day
        hours = (seconds/3600).floor
        minutes = ((seconds/60) - (hours*60)).floor
        return "just a few seconds ago" if hours < 1 && minutes < 1
        return "#{minutes} minute#{minutes == 1 ? '' : 's'} ago" if hours < 1 && days < 1
        return "#{hours} hour#{hours == 1 ? '' : 's'}, #{minutes} minute#{minutes == 1 ? '' : 's'} ago" if hours < 12 && days < 1
        return self.strftime('today at %I:%M%p') if days < 1
        return self.strftime('on %A at %I:%M%p') if days < 7
        return self.strftime('on %A, %B %d, %Y')
      end

      def at(hour,ampm)
        Time.mktime(self.year,self.month,self.day,hour + (ampm.downcase.to_sym == :am ? 0 : 12),0,0,0).to_datetime
      end

      def business_days(days)
        day = (self.is_a?(DateTime) ? self : self.to_datetime)
        if day.wday + days > 5
          weekend = true
          done = []
          while weekend
            day.upto(day + days) do |date|
              if date.wday == 6 && !done.include?(date)
                days += 2 
                done.push(date)
              end
            end
            weekend = (day + days).wday == 0 || (day + days).wday == 6
          end
        end
        (day + days).to_time.to_datetime
      end

      def next_business_day
        self.business_days(1)
      end

      def pretty
        "#{self.strftime("%A, %B")} #{self.strftime("%d").gsub(/^0/,"")}, #{self.strftime("%Y")} at #{self.strftime("%I:%M%p").downcase.gsub(/^0/,"").gsub(":00","")}"
      end

      def pretty_short
        self.strftime("%m/%d/%y %I:%M%p").gsub(/([^\/:]|^)0(\d)/,'\1\2').downcase
      end

      def when?
        str = ""
        days = (self.to_date - Date.today).to_i
        if days == 0
          str = "Today"
        elsif days == 1
          str = "Tomorrow"
        else
          str = self.strftime("%a %b %d %Y").gsub(/ 0(\d) /,' \1 ')
        end
        "#{str} at#{self.strftime(" %I:%M%p").gsub(/ 0(\d)/,' \1').gsub(":00","").downcase}"
      end
    end

    module TimeClassExtension
      def month_days_earnest(y,m)
        month_days(y,m)
      end
    end
  end
end