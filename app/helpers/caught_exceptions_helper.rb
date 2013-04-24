module CaughtExceptionsHelper
  def parse_search_text(text, array = [])
    match = text[/\w+[\*\<\>\<\=][\=]?/]
    from = text.index(/\w+[\*\<\>\<\=][\=]?/)
    from_match = match ? match.size - 1 : text.size - 1
    function = text.slice!(from..from_match)
    to_match = text.index(/\w+[\*\<\>\<\=][\=]?/)
    from += from_match.size
    to = (to_match ? to_match : text.size) - 1

    array << { :field => strip_function_flag(function),
               :query => text.slice!(0..to).strip,
               :type => pick_function(function)
             }

    if text && text.size > 0
      parse_search_text(text, array)
    else
      array
    end
  end

  def pick_function(function_text)
    case function_text
      when /\w+\=/ then :extactly
      when /\w+\*/ then :like
      when /\w+\>/ then :gt
      when /\w+\</ then :lt
      when /\w+\>\=/ then :gte
      when /\w+\<\=/ then :lte
    end
  end

  def strip_function_flag(function_text)
    function_text.gsub(/[\*\<\>\<\=][\=]?$/, '')
  end
end
