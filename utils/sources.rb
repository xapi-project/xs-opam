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
  @mirror   = nil

  def initialize(path, mirror = nil, raw=false)
    @mirror = mirror
    @raw    = false
    @path = Pathname.new(path)
    fail "expected #{@@pattern} for #{path}" unless
      @path.fnmatch(@@pattern,File::FNM_DOTMATCH)
  end

  def url
    content = File.open(@path).read.tr("\n\r", ' ')
    # use first "string" that looks like a URL
    url = content.scan(/"([^"]+)"/).find { |str| uri?(str[0]) }
    fail "no URI found in #{@path}: #{content}" if not url
    url = url[0]
    # rewrite some GitHub URLs such that we get a meaningful file
    # name and never refer to a Git repository

    return url if @raw

    url.gsub!(%r{github.com/([^/]+)/([^/]+)/archive/([^/]+).(tar.gz|zip)$},
             'github.com/\1/\2/archive/\3/\2-\3.\4')
    url.gsub!(%r{github.com/([^/]+)/([^/]+)/archive//([^/]+).(tar.gz|zip)$},
             'github.com/\1/\2/archive/\3/\2-\3.\4')
    url.gsub!(%r{git://github.com/([^/]+)/([^/#]+)$},
             'https://github.com/\1/\2/archive/master/\2-master.tar.gz')
    url.gsub!(%r{git://github.com/([^/]+)/([^/#.]+)(.git)?#(.+)$},
             'https://github.com/\1/\2/archive/\4/\2-\4.tar.gz')

    if @mirror then
      url = URI.join(@mirror, File.basename(url))
      return url.to_s
    else
      return url
    end
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
  [ '--help'    , '-h', GetoptLong::NO_ARGUMENT       ],
  [ '--url'     , '-u', GetoptLong::NO_ARGUMENT       ],
  [ '--mirror'  , '-m', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--raw'     , '-r', GetoptLong::NO_ARGUMENT       ],
)


url_only = false
raw      = false
mirror   = nil

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
      sources.rb [option] path/package/url ..

      -u, --url                                     just emit URLs
      -m, --mirror [http://example.com/some/path/]  download from mirror
      -r, --raw                                     don't rewrite URLs
      -h, --help                                    show this help

      sources.rb extracts the URLs from the url files provided as
      arguments and emits them to stdout. It rewrites some GitHub URLs
      to create unique file names.

      When a mirror is provided, it is used instead: presume the URL is

        http://example.com/path/pack.tar.gz

      and the mirror is http://mirror.example.com/x/y/, the resulting URL
      will be

        http://mirror.example.com/xy/y/pack.tar.gz

      Note that the mirror must end with a slash or otherwise the last
      element of the path will be ignored. It is possible to provide the
      --mirror flag without an argument - in which case no mirrow will
      be used. In the future a default mirror might be used in that
      case.

      Option --raw is incompatible with --mirrow because raw URLs can refer
      to URI schemes that are incompatible with mirroring.
      EOF
      exit 0
    when '--url'
      url_only |= true
    when '--raw'
      raw |= true
    when '--mirror'
      mirror = arg == '' ? nil : arg
    else
      raise ArgumentError, "#{opt} not recognised"
  end
end

if ARGV.length <= 0
  STDERR.puts "at least one path argument is required"
  exit 1
end

ARGV.each do |path|
  opam = Opam.new(path,mirror,raw)
  if url_only then
    puts opam.url
  else
    puts opam
  end
end

