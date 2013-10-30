require 'active_support/concern'

module SparseDatetime
  extend ActiveSupport::Concern

  module ClassMethods
    attr_accessor :sparse_attribute
    
    def sparse(attribute = :created_at)
      Collection.new self, attribute
    end
  end
  
  class Collection
    attr_accessor :resources, :attribute
    
    def initialize(resources, attribute)
      self.resources = resources
      self.attribute = attribute
    end
  end
end