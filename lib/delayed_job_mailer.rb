# coding: utf-8

module Delayed
  module Mailer
    def self.included(base)
      base.class_eval do
        class << self
          alias_method :orig_method_missing, :method_missing
          def method_missing(method_symbol, *params)
            if ::Delayed::Mailer.excluded_environments && ::Delayed::Mailer.excluded_environments.include?(::RAILS_ENV.to_sym)
              orig_method_missing(method_symbol, *params)
            else
              case method_symbol.to_s
              when /^deliver_([_a-z]\w*)\!/
                orig_method_missing(method_symbol, *params)
              when /^deliver_([_a-z]\w*)/
                self.delay.send "#{method_symbol}!", *params
              else
                orig_method_missing(method_symbol, *params)
              end
            end
          end
        end
      end

      def self.excluded_environments=(*environments)
        @@excluded_environments = environments && environments.flatten.collect! { |env| env.to_sym }
      end

      def self.excluded_environments
        @@excluded_environments ||= []
      end
    end
  end
end
