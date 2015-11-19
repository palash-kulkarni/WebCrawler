# Module that have methods to check all Dependencies
module CheckGemAvailablity
  # checks all the dependencies of WebCrawler
  def check_dependencies(dependencies)
    dependencies.each do |dependency|
      return false unless gem_available?(dependency)
    end
  end

  # checks whether gem is installed or not
  def gem_available?(name)
    Gem::Specification.find_by_name(name)
    true
  rescue Gem::LoadError
    false
  end
end
