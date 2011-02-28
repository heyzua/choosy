
def attempting(&block)
  lambda &block
end

def attempting_to(&block)
  lambda &block
end

# From: https://github.com/cldwalker/hirb/blob/master/lib/hirb/util.rb
# Captures STDOUT of anything run in its block and returns it as string.
def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end
