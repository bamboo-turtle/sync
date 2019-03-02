require File.join(Dir.pwd, "test", "test_helper")
require "lib/utils"

class UtilsTest < Minitest::Test
  def test_prettify_name
    assert_equal "Fusili white", Utils.prettify_name(" FUSILI- WHITE ")
    assert_nil Utils.prettify_name(nil)
  end

  def test_extract_cup_weight
    assert_equal 206, Utils.extract_cup_weight("<p>1 cup = 206g</p>")
    assert_equal 196, Utils.extract_cup_weight("<p><b><i>1 Cup of oats = 196 g </i></b></p>")
    assert_equal 196, Utils.extract_cup_weight("<p><b><i>1 Cup of oats = 196 g </i></b></p>")
    assert_equal 390, Utils.extract_cup_weight("<p>1 large cup equals 390 g</p>")
    assert_equal 200, Utils.extract_cup_weight("<p>1 cup of chickpeas equals 200 g .</p>\n<p>1 cup of dried chickpeas will make about 3 cups of cooked chickpeas.</p>")
    assert_equal 390, Utils.extract_cup_weight("<p>ORGANIC</p>\n<p>1 large cup equals 390 g</p>")
    
    assert_nil Utils.extract_cup_weight(nil)
    assert_nil Utils.extract_cup_weight("")
    assert_nil Utils.extract_cup_weight(%Q{<p><a href="https://www.organicup.com/help/">Organicup</a>.</p>})
  end

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
