# encoding: utf-8
# --
# The MIT License (MIT)
#
# Copyright (C) 2012 Gitorious AS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++
require "tilt"

class Tiltout
  VERSION = "1.0.0"

  def initialize(template_root, opt = {})
    @template_root = template_root
    @cache = {} if !opt.key?(:cache) || opt[:cache]
    @layout = opt[:layout]
    @default_type = opt[:default_type] || "erb"
    @context_class = Class.new
  end

  def helper(helper)
    helper = [helper] unless Array === helper
    helper.each { |h| @context_class.send(:include, h) }
  end

  def render(template, locals = {}, options = {})
    context = @context_class.new
    content = load(template).render(context, locals)
    layout_tpl = options.key?(:layout) ? options[:layout] : @layout

    if !layout_tpl.nil?
      content = load(layout_tpl).render(context, locals) { content }
    end

    content
  end

  private
  def load(name)
    file_name = find_file(name)
    return @cache[file_name] if cached?(file_name)
    template = Tilt.new(file_name)
    cache(file_name, template)
    template
  end

  def find_file(name)
    full_name = File.join(@template_root, name.to_s)
    return full_name if cached?(full_name) || File.exists?(full_name)
    File.join(@template_root, "#{name}.#{@default_type}")
  end

  def cache(name, template)
    @cache[name] = template if @cache
  end

  def cached?(name)
    @cache && !!@cache[name]
  end
end
