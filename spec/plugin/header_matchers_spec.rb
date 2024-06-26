require_relative "../spec_helper"

describe "accept matcher" do
  it "should accept mimetypes and set response Content-Type" do
    app(:header_matchers) do |r|
      r.on :accept=>"application/xml" do
        response[RodaResponseHeaders::CONTENT_TYPE]
      end
    end

    body("HTTP_ACCEPT" => "application/xml").must_equal  "application/xml"
    status.must_equal 404
  end
end

describe "header matcher" do
  it "should match if header present" do
    app(:header_matchers) do |r|
      r.on :header=>"accept" do
        "bar"
      end
    end

    body("HTTP_ACCEPT" => "application/xml").must_equal  "bar"
    status("HTTP_HTTP_ACCEPT" => "application/xml").must_equal 404
    status.must_equal 404
  end

  it "should yield the header value" do
    app(:header_matchers) do |r|
      r.on :header=>"accept" do |v|
        "bar-#{v}"
      end
    end

    app.opts[:header_matcher_prefix] = true
    body("HTTP_ACCEPT" => "application/xml").must_equal  "bar-application/xml"
    status.must_equal 404
  end

  it "should match content-type and content-length headers" do
    app(:header_matchers) do |r|
      r.on :header=>"content-type" do |x|
        r.on :header=>"content-length" do |y|
          "bar-#{x}-#{y}"
        end
      end
    end

    body("CONTENT_TYPE" => "application/xml", "CONTENT_LENGTH" => "1234").must_equal  "bar-application/xml-1234"
    status.must_equal 404
  end
end

describe "host matcher" do
  it "should match a host" do
    app(:header_matchers) do |r|
      r.on :host=>"example.com" do
        "worked"
      end
    end

    body("HTTP_HOST" => "example.com").must_equal 'worked'
    status("HTTP_HOST" => "foo.com").must_equal 404
  end

  it "should match a host with a regexp" do
    app(:header_matchers) do |r|
      r.on :host=>/example/ do
        "worked"
      end
    end

    body("HTTP_HOST" => "example.com").must_equal 'worked'
    status("HTTP_HOST" => "foo.com").must_equal 404
  end

  it "doesn't yield host if given a string" do
    app(:header_matchers) do |r|
      r.on :host=>"example.com" do |*args|
        args.size.to_s
      end
    end

    body("HTTP_HOST" => "example.com").must_equal '0'
  end

  it "yields host if passed a regexp and opts[:host_matcher_captures] is set" do
    app(:header_matchers) do |r|
      r.on :host=>/\A(.*)\.example\.com\z/ do |*m|
        m.empty? ? '0' : m[0]
      end
    end

    body("HTTP_HOST" => "foo.example.com").must_equal 'foo'
  end
end

describe "user_agent matcher" do
  it "should accept pattern and match against user-agent" do
    app(:header_matchers) do |r|
      r.on :user_agent=>/(chrome)(\d+)/ do |agent, num|
        "a-#{agent}-#{num}"
      end
    end

    body("HTTP_USER_AGENT" => "chrome31").must_equal  "a-chrome-31"
    status.must_equal 404
  end
end

