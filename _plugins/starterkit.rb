# frozen_string_literal: true

# The site's only custom code. It does three things:
#
#   1. Gives each page in _pages/ an ID: its file name without the extension (policy.md -> policy).
#   2. Adds Liquid filters that turn the words and links in the content files into HTML:
#      a link may be a page ID, a web address, an email address or blank.
#   3. Checks every content file against _schema.yml before the site is built, and stops the
#      build with a list of problems (each naming its file) if anything is wrong.

require "cgi"
require "yaml"

module StarterKit
  EMAIL = /\A[\w.+-]+@[\w-]+\.[\w.]+\z/.freeze
  EXTERNAL = %r{\Ahttps?://}i.freeze

  # ---------- 1. page IDs ----------
  Jekyll::Hooks.register :pages, :post_init do |page|
    if page.relative_path.start_with?("_pages/")
      page.data["page_id"] = File.basename(page.name, ".*")
    end
  end

  def self.page_urls(site)
    site.pages.each_with_object({}) do |page, map|
      map[page.data["page_id"]] = page.url if page.data["page_id"]
    end
  end

  # Resolve a link value. Returns nil for a bare word that is not a page ID.
  def self.resolve(value, site, urls)
    v = value.to_s.strip
    return "" if v.empty?
    return v if v.match?(EXTERNAL) || v.start_with?("mailto:", "tel:", "#")
    return "mailto:#{v}" if v.match?(EMAIL)
    return site.baseurl.to_s + v if v.start_with?("/")
    return site.baseurl.to_s + urls[v] if urls.key?(v)

    nil
  end

  # ---------- 2. filters ----------
  module Filters
    # A link field -> a web address ("" when blank).
    def sk_link(value)
      site = @context.registers[:site]
      StarterKit.resolve(value, site, sk_urls) || value.to_s
    end

    # ' target="_blank" rel="noopener"' for a link that leaves the site.
    def sk_target(url)
      url.to_s.match?(EXTERNAL) ? ' target="_blank" rel="noopener"' : ""
    end

    # One line of text with Markdown (bold, italics, links) -> HTML, without a wrapping paragraph.
    def sk_md(text)
      return "" if text.nil? || text.to_s.strip.empty?

      html = sk_markdown(text.to_s).strip
      html = Regexp.last_match(1) if html =~ %r{\A<p>(.*)</p>\z}m && !Regexp.last_match(1).include?("<p>")
      sk_links(html)
    end

    # Paragraphs and lists -> HTML.
    def sk_md_block(text)
      return "" if text.nil? || text.to_s.strip.empty?

      sk_links(sk_markdown(text.to_s).strip)
    end

    # Text without any markup, for attributes, page titles and the Teaching & Learning data.
    def sk_plain(text)
      CGI.unescapeHTML(sk_md(text).gsub(/<[^>]+>/, ""))
    end

    # Resolve the links in rendered HTML, and open links that leave the site in a new tab.
    def sk_links(html)
      site = @context.registers[:site]
      urls = sk_urls
      html.to_s.gsub(/<a href="([^"]*)"([^>]*)>/) do
        raw = CGI.unescapeHTML(Regexp.last_match(1))
        rest = Regexp.last_match(2)
        url = StarterKit.resolve(raw, site, urls) || raw
        target = rest.include?("target=") ? "" : sk_target(url)
        %(<a href="#{CGI.escapeHTML(url)}"#{rest}#{target}>)
      end
    end

    # A case study's Markdown, with one "## Heading" per part -> the parts as <section> blocks.
    def sk_case_parts(html)
      parts = html.to_s.split(%r{(?=<h2[^>]*>)})
      parts.reject { |p| p.strip.empty? }.map do |part|
        inner = part.sub(%r{<h2[^>]*>(.*?)</h2>}m, '<h4>\1</h4>').strip
        "<section>\n#{inner}\n</section>"
      end.join("\n")
    end

    private

    def sk_urls
      @context.registers[:sk_urls] ||= StarterKit.page_urls(@context.registers[:site])
    end

    def sk_markdown(text)
      site = @context.registers[:site]
      @context.registers[:sk_md] ||= site.find_converter_instance(Jekyll::Converters::Markdown)
      @context.registers[:sk_md].convert(text)
    end
  end

  # ---------- 3. the content check ----------
  class ContentCheck < Jekyll::Generator
    priority :lowest
    safe true

    def generate(site)
      @site = site
      @schema = YAML.safe_load(File.read(File.join(site.source, "_schema.yml")))
      @problems = []
      @urls = StarterKit.page_urls(site)
      @pages = site.pages.select { |p| p.data["page_id"] }
      @section_ids = {} # page ID -> { section ID -> section }

      @pages.each { |page| check_page(page) }
      check_site_data
      check_teaching_learning
      check_resources
      check_library
      check_collection("case_studies")
      check_collection("use_cases")

      return if @problems.empty?

      message = "The content check found #{@problems.size} problem(s):\n" +
                @problems.map { |p| "  - #{p}" }.join("\n")
      Jekyll.logger.error "Content check:", message
      raise Jekyll::Errors::FatalException, message
    end

    private

    def problem(file, text)
      @problems << "#{file}: #{text}"
    end

    def check_fields(file, where, data, allowed, required = [])
      unless data.is_a?(Hash)
        problem(file, "#{where} should be a set of fields")
        return false
      end
      (data.keys - allowed).each do |key|
        problem(file, "#{where} has a field \"#{key}\" that this kind of content does not use " \
                      "(allowed: #{allowed.join(', ')})")
      end
      required.each do |key|
        value = data[key]
        if value.nil? || (value.respond_to?(:empty?) && value.empty?)
          problem(file, "#{where} is missing the required field \"#{key}\"")
        end
      end
      true
    end

    # Every link field, and every Markdown link inside text, must point somewhere.
    def check_links(file, where, value, extra_targets = [])
      case value
      when Hash
        value.each do |key, v|
          if (key == "link" || key.end_with?("_link")) && v.is_a?(String)
            check_link(file, "#{where} → #{key}", v, extra_targets)
          else
            check_links(file, "#{where} → #{key}", v, extra_targets)
          end
        end
      when Array
        value.each_with_index { |v, i| check_links(file, "#{where}[#{i + 1}]", v, extra_targets) }
      when String
        value.scan(/\]\(([^)\s]+)\)/).flatten.each do |target|
          check_link(file, where, target, extra_targets)
        end
      end
    end

    def check_link(file, where, value, extra_targets = [])
      return if extra_targets.include?(value.strip)
      return unless StarterKit.resolve(value, @site, @urls).nil?

      problem(file, "#{where}: the link \"#{value}\" points nowhere. Use a page ID " \
                    "(#{@urls.keys.sort.join(', ')}), a web address starting https://, or an email address")
    end

    # ---- pages ----
    def check_page(page)
      file = page.relative_path
      s = @schema["page"]
      front = page.data.reject { |k, _| %w[layout page_id].include?(k) }
      check_fields(file, "The page", front, s["fields"], s["required"])
      ids = {}
      Array(page.data["sections"]).each_with_index do |section, i|
        check_section(file, page, section, "Section #{i + 1}", ids)
      end
      @section_ids[page.data["page_id"]] = ids
      Array(page.data["sections"]).each_with_index do |section, i|
        label = section.is_a?(Hash) ? (section["id"] || section["type"]) : nil
        check_links(file, "Section #{i + 1} (#{label})", section)
      end
    end

    def check_section(file, page, section, where, ids)
      unless section.is_a?(Hash) && section["type"]
        problem(file, "#{where} needs a \"type\"")
        return
      end
      type = section["type"]
      where = "#{where} (#{section['id'] || type})"
      spec = @schema["sections"][type]
      unless spec
        problem(file, "#{where} has the type \"#{type}\", which is not one of: #{@schema['sections'].keys.join(', ')}")
        return
      end
      allowed = @schema["section_common"] + spec["fields"]
      check_fields(file, where, section, allowed, spec["required"] || [])

      if (id = section["id"])
        problem(file, "#{where}: the ID \"#{id}\" is used by another section on this page") if ids.key?(id)
        ids[id] = section
      end
      if section.key?("show") && ![true, false].include?(section["show"])
        problem(file, "#{where}: show must be true or false")
      end

      styles = spec["styles"]
      style_spec = nil
      if styles
        names = styles.is_a?(Hash) ? styles.keys : styles
        style = section["style"]
        if style && !names.include?(style)
          problem(file, "#{where} has the style \"#{style}\", which is not one of: #{names.join(', ')}")
        end
        style_spec = styles[style] if styles.is_a?(Hash)
      end

      if style_spec && style_spec["items"]
        Array(section["items"]).each_with_index do |item, i|
          check_fields(file, "#{where}, item #{i + 1}", item, style_spec["items"]["fields"], style_spec["items"]["required"] || [])
        end
      elsif section["items"]
        problem(file, "#{where}: this style takes its cards from _resources/, so it should not list items")
      end

      (spec["lists"] || {}).each do |key, list_spec|
        Array(section[key]).each_with_index do |entry, i|
          next unless entry.is_a?(Hash)

          check_fields(file, "#{where}, #{key} #{i + 1}", entry, list_spec["fields"], list_spec["required"] || [])
        end
      end

      if type == "examples"
        Array(section["examples"]).each do |ex|
          next unless ex.is_a?(Hash) && ex["diagram"]

          path = File.join(@site.source, "_includes", "diagrams", "#{ex['diagram']}.html")
          problem(file, "#{where}: there is no diagram _includes/diagrams/#{ex['diagram']}.html") unless File.exist?(path)
        end
      end
      if type == "partners"
        ([section["photo"]] + Array(section["logos"]).map { |l| l.is_a?(Hash) ? l["image"] : nil }).compact.each do |img|
          path = File.join(@site.source, "assets", "img", img)
          problem(file, "#{where}: the image assets/img/#{img} does not exist") unless File.exist?(path)
        end
      end

      Array(section["parts"]).each_with_index do |part, i|
        check_section(file, page, part, "#{where}, part #{i + 1}", ids)
      end
    end

    # ---- _data/site.yml ----
    def check_site_data
      file = "_data/site.yml"
      data = @site.data["site"]
      s = @schema["site"]
      return problem(file, "is missing") unless data
      return unless check_fields(file, "The file", data, s["fields"], s["required"])

      check_fields(file, "footer", data["footer"], s["footer"]) if data["footer"]
      check_fields(file, "contact_form", data["contact_form"], s["contact_form"]) if data["contact_form"]
      Array(data["menu"]).each_with_index do |entry, i|
        next unless check_fields(file, "menu entry #{i + 1}", entry, s["menu"], s["menu"])
        next if @urls.key?(entry["page"])

        problem(file, "menu entry #{i + 1} names the page \"#{entry['page']}\", which does not exist " \
                      "(pages: #{@urls.keys.sort.join(', ')})")
      end
      check_links(file, "footer", data["footer"])
    end

    # ---- _data/teaching_learning.yml ----
    def part_names
      parts = @site.data.dig("teaching_learning", "framework", "parts")
      Array(parts).map { |p| p.is_a?(Hash) ? p["short_name"] : nil }.compact
    end

    def check_teaching_learning
      file = "_data/teaching_learning.yml"
      data = @site.data["teaching_learning"]
      s = @schema["teaching_learning"]
      return unless data
      return unless check_fields(file, "The file", data, s["fields"])

      check_fields(file, "framework", data["framework"], s["framework"]) if data["framework"]
      check_fields(file, "try_it", data["try_it"], s["try_it"]) if data["try_it"]
      check_fields(file, "comparison", data["comparison"], s["comparison"]) if data["comparison"]
      check_fields(file, "library", data["library"], s["library"]) if data["library"]

      parts = Array(data.dig("framework", "parts"))
      problem(file, "the framework must have exactly four parts (it has #{parts.size})") unless parts.size == 4
      parts.each_with_index do |p, i|
        check_fields(file, "framework part #{i + 1}", p, s["framework_parts"], %w[name short_name])
      end
      Array(data.dig("try_it", "tasks")).each_with_index do |t, i|
        next unless check_fields(file, "task #{i + 1}", t, s["tasks"], %w[quote part prompt])
        unless part_names.include?(t["part"])
          problem(file, "task #{i + 1} has the part \"#{t['part']}\"; use one of: #{part_names.join(', ')}")
        end
      end
      Array(data.dig("comparison", "tabs")).each_with_index do |t, i|
        check_fields(file, "comparison tab #{i + 1}", t, s["tabs"], %w[name])
      end
      in_page = (@section_ids["teaching-learning"] || {}).keys
      check_links(file, "framework", data["framework"], in_page)
      check_links(file, "try_it", data["try_it"])
      check_links(file, "comparison", data["comparison"])
    end

    # ---- collections ----
    def docs(label)
      @site.collections[label]&.docs || []
    end

    def check_resources
      s = @schema["resources"]
      docs("resources").each do |doc|
        file = doc.relative_path
        data = doc.data.reject { |k, _| %w[layout render_with_liquid slug ext categories tags draft date excerpt].include?(k) }
        next unless check_fields(file, "The card", data, s["fields"], s["required"])

        page_id = data["page"]
        section = (@section_ids[page_id] || {})[data["section"]]
        if !@urls.key?(page_id)
          problem(file, "page \"#{page_id}\" does not exist (pages: #{@urls.keys.sort.join(', ')})")
        elsif section.nil?
          problem(file, "page \"#{page_id}\" has no section with the ID \"#{data['section']}\"")
        elsif !(section["type"] == "cards" && %w[source context resource].include?(section["style"]))
          problem(file, "section \"#{data['section']}\" on page \"#{page_id}\" does not show resource cards")
        end
        problem(file, "order must be a number") unless data["order"].is_a?(Numeric)
        check_links(file, "The card", data.slice("link"))
        check_links(file, "The card's text", doc.content)
      end
    end

    def check_library
      s = @schema["library"]
      docs("library").each do |doc|
        file = doc.relative_path
        data = doc.data.reject { |k, _| %w[layout render_with_liquid slug ext categories tags draft date excerpt].include?(k) }
        next unless check_fields(file, "The entry", data, s["fields"], s["required"])

        case data["kind"]
        when "prompt" then problem(file, "a prompt needs the field \"prompt\"") if data["prompt"].to_s.strip.empty?
        when "skill" then problem(file, "a skill needs a list of \"steps\"") unless data["steps"].is_a?(Array) && data["steps"].any?
        else problem(file, "kind must be prompt or skill")
        end
        unless part_names.include?(data["part"])
          problem(file, "part \"#{data['part']}\" must match a framework short_name: #{part_names.join(', ')}")
        end
      end
    end

    def check_collection(label)
      s = @schema[label]
      docs(label).each do |doc|
        data = doc.data.reject { |k, _| %w[layout render_with_liquid nav_page slug ext categories tags draft date excerpt].include?(k) }
        check_fields(doc.relative_path, "The file", data, s["fields"], s["required"])
      end
    end
  end
end

Liquid::Template.register_filter(StarterKit::Filters)
