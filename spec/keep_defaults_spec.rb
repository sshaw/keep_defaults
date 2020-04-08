require "spec_helper"
require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => ":memory:"
)

ActiveRecord::Base.connection.create_table(:foo, :force => true) do |t|
  t.integer :foo, :null => false, :default => 0
  t.string :bar, :null => false, :default => "foo"
  t.boolean :overridden, :null => false, :default => false
  t.string :baz, :null => false
  t.integer :zzz, :null => true, :default => 99
end

ActiveRecord::Base.connection.create_table(:bars, :force => true) do |t|
  t.integer :foo, :null => false, :default => 0
  t.string :bar, :null => false, :default => "foo"
  t.integer :zzz, :null => true, :default => 99
end

class Abstract < ActiveRecord::Base
  self.abstract_class = true
  include KeepDefaults
end

class Bar < Abstract
end

class Foo < ActiveRecord::Base
  self.table_name = "foo"
  include KeepDefaults

  def overridden
    super
  end

  def overridden=(n)
    super
  end
end

RSpec.describe KeepDefaults do
  def keeps_defaults(f)
    expect(f.foo).to eq 0
    expect(f.bar).to eq "foo"
    expect(f[:foo]).to eq 0
    expect(f[:bar]).to eq "foo"
    expect(f.attributes).to include("foo" => 0, "bar" => "foo")
  end

  context "given a not null column without a default" do
    it "allows it to be set to nil" do
      f = Foo.new
      expect(f.baz).to be_nil

      f = Foo.new(:baz => 100)
      f.baz = nil
      expect(f.baz).to be_nil
    end
  end

  context "given a null column with a default" do
    it "allows it to be set to nil" do
      f = Foo.new
      expect(f.zzz).to eq 99

      f = Foo.new(:zzz => 100)
      f.zzz = nil
      expect(f.baz).to be_nil
    end
  end

  context "given a subclass whose superclass includes KeepsDefaults" do
    it "keeps the defaults" do
      f = Bar.new
      f[:foo] = nil
      f[:bar] = nil

      keeps_defaults(f)
    end
  end

  context "given a not null column with a default" do
    context "when the getter method is overridden" do
      it "keeps the defaults when super is called" do
        f = Foo.new(:overridden => nil)
        expect(f.overridden).to eq false
      end
    end

    context "when the setter method is overridden" do
      it "keeps the defaults when super is called" do
        f = Foo.new
        f.overridden = nil
        expect(f.overridden).to eq false
      end
    end

    context "creating an new instance and setting the attributes to nil" do
      it "keeps the defaults" do
        f = Foo.new(:foo => nil, :bar => nil)
        expect(f.attributes).to include("foo" => 0, "bar" => "foo")
      end
    end

    context "setting attributes to nil via the setter method" do
      it "keeps the defaults" do
        f = Foo.new
        f.foo = nil
        f.bar = nil

        keeps_defaults(f)
      end
    end

    context "setting attributes to nil via the bracket method" do
      it "keeps the defaults" do
        f = Foo.new
        f[:foo] = nil
        f[:bar] = nil

        keeps_defaults(f)
      end
    end

    context "setting attributes to nil via the attributes method" do
      it "keeps the defaults" do
        f = Foo.new
        f.attributes = { "foo" => nil, "bar" => nil }

        keeps_defaults(f)
      end
    end
  end
end
