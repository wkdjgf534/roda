require_relative "../spec_helper"

describe "run_handler plugin" do 
  it "makes r.run :not_found=>:pass keep going on 404" do
    pr = proc{|env| [(env['PATH_INFO'] == '/a' ? 404 : 201), {}, ['b']]}
    app(:run_handler) do |r|
      r.run pr, :not_found=>:pass
      'a'
    end

    status.must_equal 201
    body.must_equal 'b'
    status('/a').must_equal 200
    body('/a').must_equal 'a'
  end

  it "closes body when passing" do
    o = Object.new
    closed = false
    o.define_singleton_method(:close){closed = true}
    pr = proc{|env| [(env['PATH_INFO'] == '/a' ? 404 : 201), {}, (env['PATH_INFO'] == '/a' ? o : ['b'])]}
    app(:run_handler) do |r|
      r.run pr, :not_found=>:pass
      'a'
    end

    body.must_equal 'b'
    closed.must_equal false
    body('/a').must_equal 'a'
    closed.must_equal true
  end

  it "makes r.run with a block yield rack app to block, and have it be thrown afterward" do
    pr = proc{|env| [(env['PATH_INFO'] == '/a' ? 404 : 201), {}, ['b']]}
    app(:run_handler) do |r|
      r.run(pr){|a| a[0] *= 2}
      'a'
    end

    status.must_equal 402
    status('/a').must_equal 808
  end

  it "works when both :not_found=>:pass and block are given" do
    pr = proc{|env| [(env['PATH_INFO'] == '/a' ? 202 : 201), {}, ['b']]}
    app(:run_handler) do |r|
      r.run(pr, :not_found=>:pass){|a| a[0] *= 2}
      'a'
    end

    status.must_equal 402
    body.must_equal 'b'
    status('/a').must_equal 200
    body('/a').must_equal 'a'
  end

  it "makes r.run work normally if not given an option or block" do
    pr = proc{|env| [(env['PATH_INFO'] == '/a' ? 404 : 201), {}, ['b']]}
    app(:run_handler) do |r|
      r.run pr
      'a'
    end

    status.must_equal 201
    body.must_equal 'b'
    status('/a').must_equal 404
    body('/a').must_equal 'b'
  end
end
