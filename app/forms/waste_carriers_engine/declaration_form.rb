module WasteCarriersEngine
  class DeclarationForm < BaseForm
    attr_accessor :declaration

    def initialize(transient_registration)
      super
      self.declaration = @transient_registration.declaration
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.declaration = params[:declaration].to_i
      attributes = { declaration: declaration }

      super(attributes, params[:reg_identifier])
    end

    validates :declaration, inclusion: { in: [1] }
  end
end
