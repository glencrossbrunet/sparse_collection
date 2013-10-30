require 'active_support/concern'
require 'sparse_datetime/collection'

module SparseDatetime
  extend ActiveSupport::Concern

  module ClassMethods
    attr_accessor :sparse_attribute
    
    def sparse(attribute = :created_at)
      resources = where.not(attribute => nil).order("#{attribute} ASC")
      Collection.new resources, attribute
    end
  end
end