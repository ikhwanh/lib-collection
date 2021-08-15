require 'wizard'

describe Wizard do
  let(:wizard) do
    wizard = Wizard.new
    wizard.add_step('General information') do |step|
      step.add_field('name', label: 'Your name', type: 'text')
      step.add_field('age', label: 'Your name', type: 'number')
    end
    wizard.add_step('I want to know more about you') do |step|
      step.add_field('food', label: 'Favorite food', type: 'radio') do |field|
        field.add_choice(label: 'Fried rice', value: 'fried_rice')
        field.add_choice(label: 'Indomie', value: 'indomie')
      end
    end
    return wizard
  end

  let(:wizard_custom) do
    class CustomStorage < Wizard::AbstractStorage
      attr_accessor :database

      def initialize
        @database = { name: 'Rick', age: 18 }
      end

      def put(key, value)
        @database[key.to_sym] = value
      end

      def pull(key)
        @database[key.to_sym]
      end

      def remove(key)
        @database[key.to_sym] = ''
      end
    end

    wizard = Wizard.new(storage: CustomStorage.new)
    wizard.add_step('Information') do |step|
      step.add_field('name', label: 'Your name')
    end
    wizard
  end

  it 'should define current step' do
    wizard.current_index = 0
    expect(wizard.current_step.label).to eq('General information')
    expect(wizard.current_step.fields[0].id).to eq('name')
    expect(wizard.current_step.fields[1].id).to eq('age')

    wizard.current_index = 1
    expect(wizard.current_step.label).to eq('I want to know more about you')
    expect(wizard.current_step.fields.first.id).to eq('food')

    expect(wizard.last_step?).to be true
  end

  it 'should has attribute' do
    expect(wizard_custom.attribute).to eq({ name: 'Rick' })
  end

  it 'should can implement your own storage' do
    expect(wizard_custom.current_step.fields.first.value).to eq('Rick')
  end

  it 'should be fill input' do
    wizard.fill('name', 'Randall')
    expect(wizard.attribute[:name]).to eq('Randall')
  end

  it 'should be save to storage' do
    wizard_custom.fill('name', 'Randall')
    wizard_custom.save

    expect(wizard_custom.attribute[:name]).to eq('Randall')
    expect(wizard_custom.storage.pull('name')).to eq('Randall')
  end

  it 'should remove all value' do
    wizard_custom.flush
    expect(wizard_custom.attribute[:name]).to be_nil
  end

  it 'should add step with condition' do
    wizard_custom.add_step('', { name: 'Rick' }) do |step|
      step.add_field('say', label: 'Hello Rick! How are you?', type: 'radio', value: 'best') do |field|
        field.add_choice(label: 'Best!', value: 'best')
        field.add_choice(label: 'I am doing good!', value: 'good')
      end
    end

    wizard_custom.add_step('', { say: 'good' }) do |step|
      step.add_field('say_back', label: 'I am good too!', type: 'hidden', value: 'good_too')
    end

    expect(wizard_custom.attribute[:say]).to eq('best')
    expect(wizard_custom.attribute[:say_back]).to be_nil
    expect(wizard_custom.steps.length).to eq(2)
  end
end
