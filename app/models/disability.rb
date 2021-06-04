class Disability < ApplicationRecord
  belongs_to :employee, optional: true
  mount_uploader :document, DocumentUploader
end
