raise "Another Money Object is already defined!" if Object.const_defined?(:Money)
class MoneyError < StandardError; end;
class Money
  include Comparable
  attr_reader :cents

  def initialize(value)
    @cents = (Money.get_value(value)*100.0).round
  end

  def self.create_from_cents(value)
    return Money.new(Money.get_value(value)/100.0)
  end

  def eql?(other)
    (cents <=> other.cents)
  end

  def <=>(other)
    eql?(other)
  end

  def +(other)
    Money.create_from_cents((cents + other.to_money.cents))
  end

  def -(other)
    Money.create_from_cents((cents - other.to_money.cents))
  end

  def *(other)
    Money.create_from_cents((cents * other).round)
  end

  def /(denominator)
    raise MoneyError, "Denominator must be a Fixnum. (#{denominator} is a #{denominator.class})" unless denominator.is_a? Fixnum
    result = []
    equal_division = (cents/denominator).round
    denominator.times{result << Money.create_from_cents(equal_division)}
    extra_pennies = cents - (equal_division * denominator)
    extra_pennies.times{|p| result[p] += 0.01}
    result
  end

  def free?
    return (cents == 0)
  end
  alias zero? free?

  def cents
    @cents
  end

  def dollars
    cents.to_f / 100
  end

  def to_fancy_s
    "#{self} #{currency}"
  end

  def to_s
    return "" if free?
    seperated = "#{sprintf("%.2f",dollars)}".to_s.split(".")
    seperated[0] = seperated[0].to_s.reverse.scan(/..?.?/).join(",").reverse
    "#{seperated.join(".")}"
  end

  def to_money
    self
  end

  private
  def self.get_value(value)
    value = value.gsub(/[^0-9.]/,'').to_f if value.kind_of?(String)
    value = 0 if value.nil?
    unless value.kind_of?(Integer) or value.kind_of?(Float)
      raise MoneyError, "Cannot create money from cents with #{value.class}. Fixnum required."
    end
    value
  end
end

class Numeric
  def to_money
    Money.new(self)
  end
end

module RailsMoney
  def method_missing(method_id,*args)
    method_name = method_id.to_s
    setter = method_name.chomp!("=")
    method_name = "#{method_name}_in_cents"
    if @attributes.include?(method_name)
      if setter
        money = args.first.kind_of?(Money) ? args.first : Money.new(args.first)
        write_attribute(method_name,money.cents)
      else
        Money.create_from_cents(read_attribute(method_name))
      end
    else
      super
    end
  end
end
ActiveRecord::Base.send(:include,RailsMoney)