require_relative 'vertex'
require_relative 'edge'

# Class defining Graph
class Graph
  # Hash of instances of +Vertex+
  attr_reader :vertices
  # List of instances of +Edge+
  attr_reader :edges

  # create instance of +self+ by simple storing of all parameters
  def initialize(vertices, edges)
    @vertices = vertices
    @edges = edges
  end
end
