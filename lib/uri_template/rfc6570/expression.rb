require 'uri_template/rfc6570/expression'

class URITemplate::RFC6570
  class Expression < Token
    def expand(vars)
      unused_vars = vars.keys.dup
      result = []
      @variable_specs.each do |var, expand, max_length|
        if Utils.def?(vars[var])
          result.push(*expand_one(var, vars[var], expand, max_length))
        end
        unused_vars.delete(var)
      end
      unused_vars.each do |k|
        result.push(*expand_one(k, vars[k], false, 0))
      end
      if result.any?
        return (self.class::PREFIX + result.join(self.class::SEPARATOR))
      else
        return ''
      end
    end
  end
end
