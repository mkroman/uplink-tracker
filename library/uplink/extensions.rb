# encoding: utf-8

class Array
  def has? *args
    not args.map do |object|
      self.include? object
    end.include? false
  end
end
