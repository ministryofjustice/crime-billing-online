module Extensions
  module ObjectExtension
    def as_json(options = nil)
      if respond_to?(:to_hash)
        to_hash.as_json(options)
      else
        to_s
      end
    end
  end
end
