class SrcGrabber
  def initialize(source)
    @raw_source = source
    @source = source.split(":").last
    adapter_name = source.split(":").first
    case adapter_name
    when Symbol, String
      require_relative "adapters/#{adapter_name}"
      @adapter = Adapters.const_get("#{adapter_name.to_s.capitalize}")
    else
      raise "Missing adapter #{adapter_name}"
    end
  end
  def grab
    @adapter.grab(@source)
  end
end