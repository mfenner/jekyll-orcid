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
        url = "http://feed.labs.orcid-eu.org/#{name}"
        response = Faraday.get url
        text = response.status == 200 ? response.body : ""

        content = <<-eos
---
url: #{url}
---
#{text}
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
        bib = BibliographyFile.new(site, site.source, dir, "#{site.config['author']['orcid']}.bib")
        json = BibliographyFile.new(site, site.source, dir, "#{site.config['author']['orcid']}.json")
        if dir.match /^(.*?\/)?[^_]\w*$/
          site.static_files << bib
          site.static_files << json
        end
      end
    end
  end

end
