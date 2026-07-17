# frozen_string_literal: true

FactoryBot.define do
  factory :ea_public_face_area, class: "WasteCarriersEngine::EaPublicFaceArea" do
    code { "WSX" }
    name { "Wessex" }
    area_id { 1 }

    # Covers central Bristol
    area do
      {
        "type" => "Polygon",
        "coordinates" => [[
          [-2.7, 51.4],
          [-2.5, 51.4],
          [-2.5, 51.5],
          [-2.7, 51.5],
          [-2.7, 51.4]
        ]]
      }
    end
  end
end
