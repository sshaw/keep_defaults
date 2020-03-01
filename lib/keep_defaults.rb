require "keep_defaults/version"

module KeepDefaults
  def self.included(klass)
    klass.instance_eval do
      column_defaults.each do |name, default|
        next if default.nil? || columns_hash[name].null

        # Use Module.new so classes can get this by calling super
        module_eval %{
          include Module.new {
            def #{name}=(value)
              return if value.nil?
              super value
            end
          }
        }, __FILE__, __LINE__ + 1
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
