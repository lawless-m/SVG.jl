using SVG
using Test


function wtest()
    z = IOBuffer()
    write(z, Svg([Circle(0,1,1), Line(0,1,1,2), Polyline([0,1,2], [3,4,5])]), 10, 10)
    seek(z, 0)
    read(z, String) == "<svg width=\"10\" height=\"10\">\n<circle cx=\"0\" cy=\"1\" r=\"1\" style=\"fill:none;stroke:black;stroke-width:1.0\" />\n<line x1=\"0\" y1=\"1\" x2=\"1\" y2=\"2\" style=\"fill:none;stroke:black;stroke-width:1.0\" />\n<polyline points=\"0,3 1,4 2,5 \" style=\"fill:none;stroke:black;stroke-width:1.0\" />\n</svg>\n"
end

@testset "SVG.jl" begin
#==
   @test bounds(Circle(0,1,1)) == (xmin=-1, xmax=1, ymin=0, ymax=2)
   @test bounds(Line(0,1,1,2)) == (xmin=0, xmax=1, ymin=1, ymax=2)
   @test bounds(Polyline([0,1,2], [3,4,5])) == (xmin=0, xmax=2, ymin=3, ymax=5)
   @test bounds(Polyline([(0,3), (1,4), (2,5)]) == (xmin=0, xmax=2, ymin=3, ymax=5)
   @test bounds(Svg([Circle(0,1,1), Line(0,1,1,2), Polyline([0,1,2], [3,4,5])])) == (xmin=-1, xmax=2, ymin=0, ymax=5)
==#
   @test Polyline([0,1,2], [3,4,5]) == Polyline([(0,3), (1,4), (2,5)])
   @test Polyline([0,1,2], [3,4,5], identity, identity) == Polyline([(0,3), (1,4), (2,5)], identity)
   @test wtest()
   
end
