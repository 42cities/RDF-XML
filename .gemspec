Gem::Specification.new do |gem|
  
    gem.version            = File.read('VERSION').chomp
    gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')
    gem.name               = 'rdf-xml'
    gem.rubyforge_project  = 'rdf-xml'
    gem.homepage           = 'http://github.com/42cities/rdf-xml/'
    gem.summary            = 'An RDF.rb plugin for XML files.'
    gem.description        = 'An RDF.rb plugin for XML files.'
    gem.authors            = ['Alex Serebryakov']
    gem.email              = 'serebryakov@gmail.com'
    gem.platform           = Gem::Platform::RUBY
    gem.files              = %w(README.rdoc LICENSE VERSION) + Dir.glob('lib/**/*.rb')
    gem.require_paths      = %w(lib)
    gem.has_rdoc           = true
    gem.add_development_dependency 'rspec',     '>= 1.3.0'
    gem.add_runtime_dependency     'rdf',       '>= 0.1.1'
    gem.add_runtime_dependency     'nokogiri',  '>= 1.4.1'
    
end
