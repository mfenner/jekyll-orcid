require 'faraday'
require 'faraday_middleware'

module Jekyll

  class BibliographyFile < StaticFile
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir = dir
      @name = name

      if site.config['author']['orcid']
        url = "http://feed.labs.orcid-eu.org/#{site.config['author']['orcid']}.bib"
        response = Faraday.get url
        bib = response.status == 200 ? response.body : ""

        content = <<-eos
---
url: #{url}
---
#{bib}
        eos

        File.open(self.destination(site.source), File::WRONLY|File::CREAT) { |file| file.write(content) }
      end

      super(site, base, dir, name)
    end
  end

  class BibliographyGenerator < Generator
    safe true
    priority :highest

    def generate(site)
      if site.config['author']['orcid']
        dir = site.config['scholar'] ? site.config['scholar']['source'] : "./bibliography"
        name = site.config['scholar'] && site.config['scholar']['my_bibliography'] ? site.config['scholar']['my_bibliography'] : "me.bib"
        bib = BibliographyFile.new(site, site.source, dir, name)
        site.static_files << bib if dir.match /^(.*?\/)?[^_]\w*$/
      end
    end
  end

end
