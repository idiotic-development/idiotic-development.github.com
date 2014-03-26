class Jekyll::Post

  def titleized_slug
    self.slug.split(/[_-]/).join(' ').titlecase
  end
end
