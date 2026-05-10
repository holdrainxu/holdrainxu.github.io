# Polish a couple of social-icon tooltips that jekyll-socials auto-generates
# from snake_case keys (e.g. "cv_pdf" -> "Cv pdf"). Run as a post-render hook
# so it works regardless of where the tag is included.

Jekyll::Hooks.register [:pages, :documents], :post_render do |item|
  next unless item.output

  replacements = {
    "title='Cv pdf'"   => "title='CV'",
    'title="Cv pdf"'   => 'title="CV"',
    "title='Rss icon'" => "title='RSS feed'",
    'title="Rss icon"' => 'title="RSS feed"',
  }

  replacements.each { |from, to| item.output.gsub!(from, to) }
end
