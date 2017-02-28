module ActiveUMS
  class NullRelation < Relation
    def collection
      []
    end
  end
end
