require File.join(Dir.pwd, "test", "test_helper")
require "lib/utils"

class UtilsTest < Minitest::Test
  def test_clean_up_description
    assert_equal "1 cup = 85g", Utils.clean_up_description("<p>1 cup = 85g</p>")
    assert_equal "1 cup = 85g\nNice!", Utils.clean_up_description("<p>1 cup = 85g</p>\n<p><b>Nice!</b></p>")
    assert_equal "1 cup = 85g", Utils.clean_up_description("<p>1&nbsp;cup = 85g</p>\n<p><b>&nbsp;</b></p>")
    assert_equal %Q{1 cup & 85g-'..."}, Utils.clean_up_description("<p>1&nbsp;cup &amp; 85g&#8211;&#8217;&#8230;&#8243;</p>")
    assert_equal "Visit Example (http://example.com) site", Utils.clean_up_description(%Q{<p>Visit <a href="http://example.com" class="link">Example</a> site</p>})
    assert_equal "Visit Example (http://example.com) site", Utils.clean_up_description(%Q{<p>Visit <a class="link" href='http://example.com'>Example</a> site</p>})
    assert_equal "", Utils.clean_up_description(%Q{<table colspan="0" rowspan='0'><tr><td>&nbsp;</td></tr></table>})
    assert_equal "1 cup = 85g.", Utils.clean_up_description("<p>1 cup = 85g .</p>")
  end
end
