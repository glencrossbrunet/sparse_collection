require 'sparse_collection/version'
require 'sparse_collection/collection'

module SparseCollection
  attr_accessor :sparse_attribute

  def sparse(attribute = :created_at)
    resources = where.not(attribute => nil).order("#{attribute} ASC")
    ::SparseCollection::Collection.new resources, attribute
  end
end