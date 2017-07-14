module ObjectJSONMapper
  class NullRelation < Relation
    def collection
      []
    end
  end
end
