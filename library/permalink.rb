# encoding: utf-8

module MongoMapper
  module Plugins
    module Permalink
      def self.configure klass
        klass.class_eval do
          key :permalink, String
          before_save :assign_permalink
        end
      end

      module ClassMethods
        def permalink key = :title
          class_variable_set :@@permalink_key, key
        end
      end

      module InstanceMethods
        def assign_permalink
          if self.class.class_variable_defined? :@@permalink_key
              key = self.class.class_variable_get(:@@permalink_key)
            count = self.class.count(key => self[key])

            if count > 0
              self.permalink = "#{count}-#{self[key].gsub(/\W/, '-').downcase}"
            else
              self.permalink = "#{self[key].gsub(/\W/, '-').downcase}"
            end
          end
        end
      end
    end
  end
end

Permalink = MongoMapper::Plugins::Permalink
