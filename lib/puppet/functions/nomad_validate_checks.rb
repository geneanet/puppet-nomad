# This function validates the contents of an array of checks
#
# *Examples:*
#
#     nomad_validate_checks({'key'=>'value'})
#     nomad_validate_checks([
#       {'key'=>'value'},
#       {'key'=>'value'}
#     ])
#
# Would return: true if valid, and raise exception otherwise
Puppet::Functions.create_function(:nomad_validate_checks) do
  def nomad_validate_checks(*arguments)
    raise(Puppet::ParseError, "validate_checks(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1
    return validate_checks(arguments[0])
  end

  def validate_checks(obj)
    case obj
      when Array
        obj.each do |c|
          validate_checks(c)
        end
      when Hash
          if ( (obj.key?("http") || obj.key?("script") || obj.key?("tcp")) && (! obj.key?("interval")) )
            raise Puppet::ParseError.new('interval must be defined for tcp, http, and script checks')
          end
  
          if obj.key?("ttl")
            if (obj.key?("http") || obj.key?("script") || obj.key?("tcp") || obj.key?("interval"))
              raise Puppet::ParseError.new('script, http, tcp, and interval must not be defined for ttl checks')
            end
          elsif obj.key?("http")
            if (obj.key?("script") || obj.key?("tcp"))
              raise Puppet::ParseError.new('script and tcp must not be defined for http checks')
            end
          elsif obj.key?("tcp")
            if (obj.key?("http") || obj.key?("script"))
              raise Puppet::ParseError.new('script and http must not be defined for tcp checks')
            end
          elsif obj.key?("script")
            if (obj.key?("http") || obj.key?("tcp"))
              raise Puppet::ParseError.new('http and tcp must not be defined for script checks')
            end
          else
            raise Puppet::ParseError.new('One of ttl, script, tcp, or http must be defined.')
          end
      else
        raise Puppet::ParseError.new("Unable to handle object of type <%s>" % obj.class.to_s)
    end
  end
end
