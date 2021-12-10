module SVG

export Style, Svg, Polyline, Circle, Line, write, scale, translate

dp(n; d=2) = round(n, digits=d)

abstract type SvgObject end

struct Style
	fill::String
	strokecolor::String
	strokewidth::Float64
	Style(;fill="none", strokecolor="black", strokewidth=1) = new(fill, strokecolor, strokewidth)
end

struct Polyline <: SvgObject
	xs
	ys 
	style::Style
	Polyline(; style::Style=Style()) = new(Vector{Float64}(), Vector{Float64}(), style)
	Polyline(npoints::Int; style::Style=Style()) = new(Vector{Float64}(undef, npoints), Vector{Float64}(undef, npoints), style)
	Polyline(xs, ys; style::Style=Style()) = new(xs, ys, style)
end

struct Line <: SvgObject
	x1
	y1
	x2
	y2
	style::Style
	Line(x1, y1, x2, y2; style::Style=Style()) = new(x1, y1, x2, y2, style)
end

struct Circle <: SvgObject
	x
	y
	r
	s::Style
	Circle(x, y, r; style::Style=Style()) = new(x, y, r, style)
end

struct Svg
	width
	height
	objects::Vector{SvgObject}
	Svg() = new(0, 0, Vector{SvgObject}())
	Svg(w, h) = new(w, h, Vector{SvgObject}())
	Svg(w, h, objs) = new(w, h, objs)
end

Base.write(fn::String, svg::Svg; inhtml=false, digits=2) = open(fn, "w") do io write(io, svg; inhtml, digits) end 

function Base.write(io::IO, svg::Svg; inhtml=false, digits=2)
	if inhtml
		println(io, "<html><body><div>")
	end
	println(io, """<svg width="$(dp(svg.width))" height="$(dp(svg.height))">""")
	broadcast(o->write(io, svg, o; digits), svg.objects);
	println(io, "</svg>")
	if inhtml
		println(io, "</div></body></html>")
	end
end

Base.write(io::IO, s::Style) = print(io, "style=\"", "fill:", s.fill, ";stroke:", s.strokecolor, ";stroke-width:", dp(s.strokewidth), "\"")

function Base.write(io::IO, svg::Svg, p::Polyline; digits=2)
	print(io, "<polyline points=\"")
	broadcast(i->print(io, dp(p.xs[i]; digits), ", ", dp(svg.height-p.ys[i]; digits), " "), 1:length(p.xs));
	print(io, "\" ")
	write(io, p.style)
	println(io, " />")
end

function Base.write(io::IO, svg::Svg, L::Line; digits=2)
	print(io, "<line x1=\"", dp(L.x1; digits), "\" y1=\"", dp(svg.height-L.y1; digits), "\" x2=\"", dp(L.x2; digits), "\" y2=\"", dp(svg.height-L.y2; digits), "\" ")
	write(io, L.style)
	println(io, " />")
end

function Base.write(io::IO, svg::Svg, c::Circle; digits=2)
	print(io, "<circle cx=\"", dp(c.x; digits), "\" cy=\"", dp(svg.height-c.y; digits), "\" r=\"", dp(c.r; digits), "\" ")
	write(io, c.s)
	println(io, " />")
end

points2circles(xs, ys; r=1) = map(i->Circle(xs[i], ys[i], r), 1:length(xs))

## helper
function scale(points, ptop)
	pmin, pmax = minimum(points), maximum(points)
	scale = ptop / (pmax - pmin)
	map(n -> scale * (n-pmin), points)
end

#helper
translate(points, delta) = map(p->p+delta, points)


###
end

