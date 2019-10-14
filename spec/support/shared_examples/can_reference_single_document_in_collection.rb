# frozen_string_literal: true

RSpec.shared_examples "Can reference single document in collection" do |subject_lambda, attribute, object_from_collection, new_object_for_collection, collection|
  subject { instance_eval(&subject_lambda) }

  describe ".reference_one" do
    it "defines an attr getter for the given attribute" do
      expect(subject).to respond_to(attribute.to_s)
    end

    it "defines an attr setter for the given attribute" do
      expect(subject).to respond_to("#{attribute}=")
    end
  end

  describe "##{attribute}" do
    it "returns the correct object from the collection" do
      expect(subject.send(attribute)).to eq(instance_eval(&object_from_collection))
    end
  end

  describe "##{attribute}=" do
    it "updates the object's collection with the new object" do
      size = subject.send(collection).size

      expect(subject.send(collection)).to_not include(new_object_for_collection)

      subject.send("#{attribute}=", new_object_for_collection)

      expect(subject.send(collection)).to include(new_object_for_collection)
      expect(subject.send(collection).size).to eq(size)
    end
  end
end
