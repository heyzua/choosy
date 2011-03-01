
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
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end
  res = {:stdout => fake_out.string, :stderr => fake_err.string}
  if kind
    res[kind]
  else
    res
  end
end
