using SVG
using Test

function wtest(s)
    z = IOBuffer()
    write(z, s)
    seek(z,0)
    read(z, String) == "<svg width=\"0.0\" height=\"10.0\">\n<circle cx=\"0.0\" cy=\"9.0\" r=\"1.0\" style=\"fill:none;stroke:black;stroke-width:1.0\" />\n<line x1=\"0.0\" y1=\"9.0\" x2=\"1.0\" y2=\"8.0\" style=\"fill:none;stroke:black;stroke-width:1.0\" />\n<polyline points=\"0.0, 7.0 1.0, 6.0 2.0, 5.0 \" style=\"fill:none;stroke:black;stroke-width:1.0\" />\n</svg>\n"
end

c = Circle(0,1,1)
l = Line(0,1,1,2)
p = Polyline([0,1,2], [3,4,5])
s = Svg(0, 10, [c,l,p])

@testset "SVG.jl" begin
   @test bounds(c) == (xmin=-1, xmax=1, ymin=0, ymax=2)
   @test bounds(l) == (xmin=0, xmax=1, ymin=1, ymax=2)
   @test bounds(p) == (xmin=0, xmax=2, ymin=3, ymax=5)
   @test bounds(s) == (xmin=-1, xmax=2, ymin=0, ymax=5)
   @test wtest(s)
end
