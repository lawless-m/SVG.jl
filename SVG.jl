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
	points::Vector{Tuple{Float64, Float64}}
	style::Style
	Polyline(; style::Style=Style()) = new(Vector{Tuple{Float64, Float64}}(), style)
	Polyline(npoints::Int; style::Style=Style()) = new(Vector{Tuple{Float64, Float64}}(undef, npoints), style)
	Polyline(points::Vector{Tuple{Float64, Float64}}; style::Style=Style()) = new(points, style)
end

struct Line <: SvgObject
	pointA::Tuple{Float64, Float64}
	pointZ::Tuple{Float64, Float64}
	style::Style
	Line(a, z; style::Style=Style()) = new(a, z, style)
end

struct Circle <: SvgObject
	x::Float64
	y::Float64
	r::Float64
	s::Style
	Circle(x, y, r; style::Style=Style()) = new(x, y, r, style)
	Circle(t::Tuple{Float64, Float64}, r::Float64; style::Style=Style()) = new(t[1], t[2], r, style)
end

struct Svg
	width::Float64
	height::Float64
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
	for v in p.points
		print(io, dp(v[1]), ", ", dp(svg.height-v[2]), " ")
	end
	print(io, "\" ")
	write(io, p.style)
	println(io, " />")
end

function Base.write(io::IO, svg::Svg, L::Line)
	print(io, "<line x1=\"", dp(L.a[1]), "\" y1=\"", dp(svg.height-L.a[2]), "\" x2=\"", dp(L.z[1]), "\" y2=\"", dp(svg.height-L.z[2]), "\" ")
	write(io, L.style)
	println(io, " />")
end

function Base.write(io::IO, svg::Svg, c::Circle)
	print(io, "<circle cx=\"", dp(c.x), "\" cy=\"", dp(svg.height-c.y), "\" r=\"", dp(c.r), "\" ")
	write(io, c.s)
	println(io, " />")
end

function points2circles(points; r=1)
	map(p->Circle(p[1], p[2], r), points)
end

###
end

