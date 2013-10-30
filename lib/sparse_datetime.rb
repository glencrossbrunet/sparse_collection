require 'active_support/concern'

module SparseDatetime
  extend ActiveSupport::Concern

  module ClassMethods
    attr_accessor :sparse_attribute
    
    def sparse(attribute = :created_at)
      self.sparse_attribute = attribute
      self
    end
  end
end