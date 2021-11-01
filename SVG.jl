module SVG

export Style, Svg, Polyline, Circle, Line, write

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

function Base.write(fn::String, svg::Svg; inhtml=false)
	open(fn, "w") do io write(io, svg, inhtml=inhtml) end 
end

function Base.write(io::IO, svg::Svg; inhtml=false)
	if inhtml
		println(io, "<html><body><div>")
	end
	println(io, "<svg width=\"", dp(svg.width), "\" height=\"", dp(svg.height), "\">")
	for o in svg.objects
		write(io, svg, o)
	end
	println(io, "</svg>")
	if inhtml
		println(io, "</div></body></html>")
	end
end

Base.write(io::IO, s::Style) = print(io, "style=\"", "fill:", s.fill, ";stroke:", s.strokecolor, ";stroke-width:", dp(s.strokewidth), "\"")

function Base.write(io::IO, svg::Svg, p::Polyline)
	print(io, "<polyline points=\"")
	for i in 1:length(p.xs)
		print(io, dp(p.xs[i]), ", ", dp(svg.height-p.ys[i]), " ")
	end
	print(io, "\" ")
	write(io, style)
	println(io, " />")
end

function Base.write(io::IO, svg::Svg, L::Line)
	print(io, "<line x1=\"", dp(L.x1), "\" y1=\"", dp(svg.height-L.y1), "\" x2=\"", dp(L.x2), "\" y2=\"", dp(svg.height-L.y2), "\" ")
	write(io, L.style)
	println(io, " />")
end

function Base.write(io::IO, svg::Svg, L::Line)
	print(io, "<line x1=\"", dp(L.x1), "\" y1=\"", dp(svg.height-L.y1), "\" x2=\"", dp(L.x2), "\" y2=\"", dp(svg.height-L.y2), "\" ")
	write(io, L.style)
	println(io, " />")
end

function Base.write(io::IO, svg::Svg, c::Circle)
	print(io, "<circle cx=\"", dp(c.x), "\" cy=\"", dp(svg.height-c.y), "\" r=\"", dp(c.r), "\" ")
	write(io, c.s)
	println(io, " />")
end

points2circles(xs, ys; r=1) = map(i->Circle(xs[i], ys[i], r), 1:length(xs))

###
end

