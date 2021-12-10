using SVG
using Test

function wtest(s)
    z = IOBuffer()
    write(z, s)
    seek(z,0)
    read(z, String) == "<svg width=\"0.0\" height=\"10.0\">\n<circle cx=\"0.0\" cy=\"9.0\" r=\"1.0\" style=\"fill:none;stroke:black;stroke-width:1.0\" />\n<line x1=\"0.0\" y1=\"9.0\" x2=\"1.0\" y2=\"8.0\" style=\"fill:none;stroke:black;stroke-width:1.0\" />\n<polyline points=\"0.0, 7.0 1.0, 6.0 2.0, 5.0 \" style=\"fill:none;stroke:black;stroke-width:1.0\" />\n</svg>\n"
end

function polytest(sfn)
    p1 = scale(Polyline([0,5,10], [10,5,0]), sfn)
    p2 = Polyline([100.0, 50.0, 0.0], [0.0, 50.0, 100.0])
    p1.xs == p2.xs && p1.ys == p1.ys && p1.style == p2.style
end

ps = [0, 5, 10]
sfn = scale_fn(100, minimum(ps), maximum(ps))

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
   @test sfn(0) == 100 && sfn(10) == 0
   @test scale(Circle(5,5,1), sfn) == Circle(50.0, 50.0, 10.0)
   @test scale(Line(0,0,10,10), sfn) == Line(100.0, 100.0, -0.0, -0.0)
   @test scale([0,5,10], sfn) == [100, 50, 0]
   @test polytest(sfn)
end
