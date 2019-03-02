module Utils
  def self.prettify_name(name)
    return if name.nil?

    name
      .gsub(/[-]/, " ")
      .gsub(/\s{1,}/, " ")
      .strip
      .downcase
      .capitalize
  end

  def self.extract_cup_weight(text)
    return if text.nil? || text.strip == ""
    weight = text[/cup\D+(\d+)\s?g/i, 1]
    weight && weight.to_i
  end

  def self.clean_up_description(string)
    return if string.nil? || string.empty?

    string
      .gsub(/<a ([^>]+)?href=["'](?<url>[^"']+)["']([^>]+)?>(?<text>[^<]+)<\/a>/i, "\\k<text> (\\k<url>)")
      .gsub(/<\/?[^>]+>/, "")
      .gsub(/&[#\w]+;/, { "&nbsp;" => " ", "&amp;" => "&", "&#8211;" => "-", "&#8217;" => "'", "&#8230;" => "...", "&#8243;" => '"' })
      .gsub(/ +\./, ".")
      .gsub(/(\s){1,}/, "\\1")
      .gsub(/^ $/, "")
      .strip
  end
end
