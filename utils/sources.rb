#! /usr/bin/env ruby
#
# This script extracts (and rewrites) the download URLs from the URL
# files that are part of an Opam package description.
#


require 'getoptlong'
require 'uri'
require 'pathname'

def uri?(string)
  uri = URI.parse(string)
  %w(http https git ftp).include?(uri.scheme)
rescue URI::BadURIError
  false
rescue URI::InvalidURIError
  false
end

class Opam
  @@pattern = '**/*/*/url'

  def initialize(path)
    @path = Pathname.new(path)
    fail 'expected #{@@pattern} for #{path}' unless
      @path.fnmatch(@@pattern,File::FNM_DOTMATCH)
  end

  def url
    content = File.open(@path).read.tr("\n\r", ' ')
    # use first "string" that looks like a URL
    url = content.scan(/"([^"]+)"/).find { |str| uri?(str[0]) }[0]
    fail "no URI found in #{@path}: #{content}" if not url
    # rewrite some GitHub URLs such that we get a meaningful file
    # name and never refer to a Git repository
    url.gsub!(%r{github.com/([^/]+)/([^/]+)/archive/([^/]+).tar.gz$},
             'github.com/\1/\2/archive/\3/\2--\3.tar.gz')
    url.gsub!(%r{git://github.com/([^/]+)/([^/#]+)$},
             'https://github.com/\1/\2/archive/master/\2--master.tar.gz')
    url.gsub!(%r{git://github.com/([^/]+)/([^/#.]+)(.git)?#(.+)$},
             'https://github.com/\1/\2/archive/\4/\2--\4.tar.gz')
    return url
  end

  def package
    @path.dirname.basename.to_s
  end

  def space
    @path.dirname.dirname.basename.to_s
  end

  def to_s
    path = "#{space}/#{package}"
    sprintf "%-40s %s", path, url
  end
end

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--url' , '-u', GetoptLong::NO_ARGUMENT ],
)


url_only = false

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
      sources.rb [option] path/package/url ..

      --url, -u:    just emit URLs
      EOF
      exit 0
    when '--url'
      url_only |= true
    else
      raise ArgumentError, "#{opt} not recognised"
  end
end

if ARGV.length <= 0
  STDERR.puts "at least one path argument is required"
  exit 1
end

ARGV.each do |path|
  opam = Opam.new(path)
  if url_only then
    puts opam.url
  else
    puts opam
  end
end

