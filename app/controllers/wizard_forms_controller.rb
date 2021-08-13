class WizardFormsController < ApplicationController
  before_action do
    @wizard = wizard_builder
    @wizard.current_index = params[:step].blank? ? 0 : params[:step].to_i - 1
    @step = @wizard.current_index + 1
  end

  def index; end

  def new; end

  def create
    input_names = @wizard.current_step.fields.map(&:id)
    input_names.each { |input_name| @wizard.fill(input_name, params[input_name.to_sym]) }
    @wizard.save

    if @wizard.last_step?
      redirect_to action: :index
    else
      redirect_to action: :new, step: @step + 1
    end
  end

  def flush
    @wizard.flush
    redirect_to action: :index
  end

  private

  def wizard_builder
    wizard = Wizard.new(storage: Wizard::SessionStorage.new(session))
    wizard.add_step('Identity') do |step|
      step.add_field('name', label: 'Name', type: 'text', required: true)
      step.add_field('age', label: 'Age', type: 'number', required: true)
    end
    wizard.add_step('') do |step|
      step.add_field('food', label: 'Which food do you like the most?', type: 'radio') do |field|
        field.add_choice(label: 'Fried chicked', value: 'fried_chicken')
        field.add_choice(label: 'Fried rice', value: 'fried_rice')
        field.add_choice(label: 'Meatball', value: 'meatball')
      end
    end
    wizard.add_step('') do |step|
      step.add_field('drink', label: 'Which drink do you like the most?', type: 'radio') do |field|
        field.add_choice(label: 'Apel juice', value: 'apel_juice')
        field.add_choice(label: 'Ice tea', value: 'ice_tea')
        field.add_choice(label: 'Soda', value: 'soda')
      end
    end
    wizard
  end
end
