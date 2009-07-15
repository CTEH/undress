require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class RainbowCloth::GreenClothTest < Test::Unit::TestCase
  def assert_renders_greencloth(greencloth, html)
    assert_equal greencloth, RainbowCloth.new(html, :xhtml_strict => true).to_greencloth
  end

  # basics
  context "Basic conversions" do
    test "headers" do
      html = "<h1 class=\"first\">header one</h1>\n<h2>header two</h2>"
      greencloth = "header one\n=====\nheader two\n----"
      assert_renders_greencloth greencloth, html 
    end
  end

  # lists
  # TODO: start attribute not implemented
  context "Converting html lists to greencloth" do
    test "hard break in list" do
      html = "<ul>\n\t<li>first line</li>\n\t<li>second<br />\n\tline</li>\n\t<li>third line</li>\n</ul>\n"
      greencloth = "* first line\n* second\nline\n* third line\n" 
      assert_renders_greencloth greencloth, html 
    end

    test "mixed nesting" do
      html = "<ul><li>bullet\n<ol>\n<li>number</li>\n<li>number\n<ul>\n\t<li>bullet</li>\n</ul></li>\n<li>number</li>\n<li>number with<br />a break</li>\n</ol></li>\n<li>bullet\n<ul><li>okay</li></ul></li></ul>"
      greencloth = "* bullet\n*# number\n*# number\n*#* bullet\n*# number\n*# number with\na break\n* bullet\n** okay\n"
      assert_renders_greencloth greencloth, html 
    end

    test "list continuation" do # uses start
      html = "<ol><li>one</li><li>two</li><li>three</li></ol><ol><li>one</li><li>two</li><li>three</li></ol><ol start='4'><li>four</li><li>five</li><li>six</li></ol>"
      greencloth = "# one\n# two\n# three\n\n# one\n# two\n# three\n\n# four\n# five\n# six\n"
      assert_renders_greencloth greencloth, html 
    end

    test "continue after break" do # uses start
      html = "<ol><li>one</li><li>two</li><li>three</li></ol><p>test</p><ol><li>one</li><li>two</li><li>three</li></ol><p>test</p><ol start='4'><li>four</li><li>five</li><li>six</li></ol>"
      greencloth = "# one\n# two\n# three\n\ntest\n\n# one\n# two\n# three\n\ntest\n\n# four\n# five\n# six\n"
      assert_renders_greencloth greencloth, html 
    end

    test "continue list when prior list contained nested list" do # uses start
      greencloth = "# one\n# two\n# three\n\n# four\n# five\n## sub-note\n## another sub-note\n# six\n\n# seven\n# eight\n# nine\n"
      html = "<ol><li>one</li><li>two</li><li>three</li></ol><ol start='4'><li>four</li><li>five<ol><li>sub-note</li><li>another sub-note</li></ol></li><li>six</li></ol><ol start='7'><li>seven</li><li>eight</li><li>nine</li></ol>"
      assert_renders_greencloth greencloth, html 
    end

    test "" do

    end
  end

  # links
  context "Converting html links to greencloth" do
    test "convert a link to a wiki page inside a paragraph" do
      html = "<p>this is a <a href='/page/plain-link'>plain link</a> in some text</p>"
      greencloth = "this is a [plain link] in some text\n"
      assert_renders_greencloth greencloth, html 
    end

    test "convert a link to a wiki page with namespace" do
      html= "<p>this is a <a href='/namespaced/link'>link</a> in some text</p>"
      greencloth = "this is a [namespaced / link] in some text\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "convert a link to a wiki page" do
      html= "<p>this is a <a href='/page/something-else'>link to</a> in some text</p>"
      greencloth = "this is a [link to -> something else] in some text\n"
      assert_renders_greencloth greencloth, html 
    end

    test "convert a link to a wiki page with namespace and text different than link dest" do
      html= "<p>this is a <a href='/namespace/something-else'>link to</a> in some text</p>"
      greencloth = "this is a [link to -> namespace / something else] in some text\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "convert a link to an absolute path" do
      html = "<p>this is a <a href='/an/absolute/path'>link to</a> in some text</p>"
      greencloth = "this is a [link to -> /an/absolute/path] in some text\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "convert a link to an external domain" do
      html = "<p>this is a <a href='https://riseup.net'>link to</a> a url</p>"
      greencloth = "this is a [link to -> https://riseup.net] a url\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a link to an external domain with the same text as dest" do
      html = "<p>url in brackets <a href='https://riseup.net/'>riseup.net</a></p>"
      greencloth = "url in brackets [riseup.net -> https://riseup.net/]\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a link to a wiki page with the same name as dest" do
      html = "<p>a <a href='/page/name-link'>name link</a> in need of humanizing</p>"
      greencloth = "a [name link] in need of humanizing\n"
      assert_renders_greencloth greencloth, html 
    end

    test "link to a user blue" do
      html = "<p>link to a user <a href='/blue'>blue</a></p>"
      greencloth = "link to a user [blue]\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "link with dashes should keep the dashes" do
      html = "<p><a href='/-dashes/in/the/link-'>link to</a></p>"
      greencloth = "[link to -> /-dashes/in/the/link-]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "link with underscores should keep the underscores" do
      html = "<p>links <a href='/page/with_underscores'>with_underscores</a> should keep underscore</p>"
      greencloth = "links [with_underscores] should keep underscore\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a link inside a li element" do
      html ="<ul>\n<li>\n\t\t\n<a href='/page/this'>link to</a></li></ul>"
      greencloth = "* [link to -> this]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "an external link inside a li element" do
      html = "<ul>\n<li><a href='https://riseup.net/'>riseup.net</a></li>\n</ul>"
      greencloth = "* [riseup.net -> https://riseup.net/]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "many anchors inside a paragraph" do
      html = "<p>make anchors <a name='here'>here</a> or <a name='maybe-here'>maybe here</a> or <a name='there'>over</a></p>"
      greencloth = "make anchors [# here #] or [# maybe here #] or [# over -> there #]\n"
      assert_renders_greencloth greencloth, html 
    end

    # TODO: there are differents in this test about how cg support writing anchors
    # this is a reduced support of it
    test "anchors and links" do
      html = "<p>link to <a href='/page/anchors#like-so'>anchors</a> or <a href='/page/like#so'>maybe</a> or <a href='#so'>just</a> or <a href='#so'>so</a></p>"
      greencloth = "link to [anchors -> anchors#like so] or [maybe -> like#so] or [just -> #so] or [so -> #so]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "more anchors" do
      html = "<p><a href='#5'>link</a> to a numeric anchor <a name='5'>5</a></p>"
      greencloth = "[link -> #5] to a numeric anchor [# 5 #]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "3 links without /" do
      html = "<p><a href='some'>some</a> and <a href='other'>other</a> and <a href='one_more'>one_more</a></p>"
      greencloth = "[some] and [other] and [one_more]\n"
      assert_renders_greencloth greencloth, html 
    end
  end
end
