require "keep_defaults/version"

module KeepDefaults
  INSTALL = ->(klass) do
    klass.column_defaults.each do |name, default|
      next if default.nil? || klass.columns_hash[name].null

      # Use Module.new so classes can get this by calling super
      klass.module_eval %{
        include Module.new {
          def #{name}=(value)
            value = self.class.column_defaults["#{name}"] if value.nil? && !self.class.columns_hash["#{name}"].null
            super value
          end
        }
      }, __FILE__, __LINE__ + 1
    end
  end

  private_constant :INSTALL

  def self.included(klass)
    raise "KeepDefaults can only be used by ActiveRecord::Base subclasses" unless klass < ActiveRecord::Base

    return INSTALL[klass] unless klass.abstract_class || klass.inspect =~ %r[\(Table doesn't exist\)\z]

    klass.instance_eval do
      def inherited(klass)
        super

        INSTALL[klass] if klass.descends_from_active_record?
      end
    end
  end

  def write_attribute(name, value)
    name  = name.to_s if name.is_a?(Symbol)
    name  = self.class.attribute_alias(name) if self.class.attribute_alias?(name)
    value = self.class.column_defaults[name] if value.nil? && !self.class.columns_hash[name].null
    super
  end
end
