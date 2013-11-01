require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AttrEnumerator" do
  subject(:instance){ TestModel.new }

  after(:each) do
    begin
      Object.send(:remove_const, :TestModel)
    rescue NameError
    end
  end

  context "without ActiveRecord" do
    before(:each) do
      class TestModel
        include ActiveModel::Validations
        include AttrEnumerator
        attr_accessor :choice
      end
    end

    context "validation" do
      it "passes when the value is one of the choices" do
        TestModel.attr_enumerator :choice, ['red', 'blue']
        instance.choice = 'blue'
        instance.should be_valid
      end

      it "fails when the value is not one of the choices" do
        TestModel.attr_enumerator :choice, ['red', 'blue']
        instance.choice = 'green'
        instance.should_not be_valid
      end

      it "has a default message of 'is invalid'" do
        TestModel.attr_enumerator :choice, ['red', 'blue']

        flunk # TODO
      end

      it "supports a custom message" do
        TestModel.attr_enumerator :choice, ['red', 'blue'], :message => '%{value} is not a valid color'

        flunk # TODO
      end

      it "supports allow_blank" do
        TestModel.attr_enumerator :choice, ['red', 'blue'], :allow_blank => true

        flunk # TODO
      end

      it "supports allow_nil" do
        TestModel.attr_enumerator :choice, ['red', 'blue'], :allow_nil => true

        flunk # TODO
      end

      it "handles symbol enumerations distinctively from strings" do
        TestModel.attr_enumerator :choice, [:red, :blue]

        instance.choice = :red
        instance.should be_valid
        instance.should be_choice_red

        instance.choice = 'red'
        instance.should_not be_valid
        instance.should_not be_choice_red
      end
    end

    context "class constant" do
      it "creates a constant" do
        TestModel.attr_enumerator :choice, ['red', 'blue']
        TestModel::CHOICES.should == ['red', 'blue']
      end

      it "freezes the constant to prevent editing" do
        TestModel.attr_enumerator :choice, ['red', 'blue']
        TestModel::CHOICES.should be_frozen
      end

      it "allows for a custom constant name using a symbol" do
        TestModel.attr_enumerator :choice, ['red', 'blue'], :constant => :POSSIBLE_COLORS
        TestModel::POSSIBLE_COLORS.should == ['red', 'blue']
      end

      it "allow for a custom constant name using a string" do
        TestModel.attr_enumerator :choice, ['red', 'blue'], :constant => 'POSSIBLE_COLORS'
        TestModel::POSSIBLE_COLORS.should == ['red', 'blue']
      end
    end

    context "methods" do
      it "creates methods for each enumeration" do
        TestModel.attr_enumerator :choice, ['red', 'blue']
        instance.choice = 'red'

        instance.should respond_to :choice_red?
        instance.should be_choice_red

        instance.should respond_to :choice_blue?
        instance.should_not be_choice_blue
      end

      it "creates methods with friendly names" do
        enumerations = {
          :has_space? => 'has space',
          :has_dash? => 'has-dash',
          :other_characters? => 'other%*characters',
          :uppercase? => 'UPPERCASE',
          :camel_case? => 'CamelCase',
          :ends_with_dot? => 'ends.with.dot.'
        }

        TestModel.attr_enumerator :choice, enumerations.values, :prefix => false

        enumerations.keys.each do |method_name|
          instance.should respond_to method_name
        end
      end

      it "supports a custom prefix" do
        TestModel.attr_enumerator :choice, ['red', 'blue'], :prefix => 'colored'
        instance.choice = 'red'

        instance.should respond_to :colored_red?
        instance.should be_colored_red

        instance.should respond_to :colored_blue?
        instance.should_not be_colored_blue
      end

      it "supporst having no prefix" do
        TestModel.attr_enumerator :choice, ['red', 'blue'], :prefix => false
        instance.choice = 'red'

        instance.should respond_to :red?
        instance.should be_red

        instance.should respond_to :blue?
        instance.should_not be_blue
      end
    end
  end

  context "with ActiveRecord" do
    before(:each) do
      class TestModel < ActiveRecordModel
        attr_accessor :choice
      end
    end

    it "automatically gets included in ActiveRecord::Base" do
      ActiveRecord::Base.should respond_to :attr_enumerator
    end

    describe "scopes" do
      it "creates a scope for each enumeration" do
        TestModel.attr_enumerator :choice, ['red', 'blue']
        TestModel.choice_red.should be_a ActiveRecord::Relation
      end

      it "creates a scope for each enumeration with custom prefix " do
        TestModel.attr_enumerator :choice, ['red', 'blue'], :prefix => 'colored'
        TestModel.colored_red.should be_a ActiveRecord::Relation
      end

      it "creates a scope for each enumeration without prefix " do
        TestModel.attr_enumerator :choice, ['red', 'blue'], :prefix => false
        TestModel.red.should be_a ActiveRecord::Relation
      end
    end
  end
end
