#--
# Copyright (c) 2011 Gregory S. Woodward
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

begin
  require 'active_support/core_ext/object/to_json'
rescue LoadError
  require 'active_support/json/encoders/object'
end

begin
  require 'active_support/core_ext/object/try'
rescue LoadError
  require 'active_support/core_ext/try'
end

require 'active_support/core_ext/hash'
require 'fog'
require 'erb'
require 'json'
require 'hashie'
require 'tmpdir'
require 'remy/shell'
require 'yaml'
dir = File.dirname(__FILE__)
Dir[File.join(File.dirname(__FILE__), 'remy', '**', '*.rb')].each {|f| require f.gsub(dir, '')[1, f.length] }

module Remy
  begin
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load 'tasks/remy.rake'
      end
    end
  rescue LoadError, NameError
  end
end
