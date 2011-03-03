
def attempting(&block)
  lambda &block
end

def attempting_to(&block)
  lambda &block
end

# Ammended from: https://github.com/cldwalker/hirb/blob/master/lib/hirb/util.rb
def capture(kind=nil, &block)
  original_stdout = $stdout
  original_stderr = $stderr
  $stdout = fake_out = StringIO.new
  $stderr = fake_err = StringIO.new
  begin
    yield
  rescue SystemExit => e
    # Skip
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end

  case kind
  when nil
    fake_out.string
  when :stderr
    fake_err.string
  when :stdout
    fake_out.string
  end
end
