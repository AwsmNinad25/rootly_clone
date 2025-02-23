class Incident < ApplicationRecord
    validates :title, presence: true 
end
