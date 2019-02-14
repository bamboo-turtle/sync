module Utils
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
