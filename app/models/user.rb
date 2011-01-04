class User < ActiveRecord::Base
  belongs_to :person, :polymorphic => true
end