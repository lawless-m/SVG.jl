module SVG

export Style, Svg, Polyline, write

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

struct Svg
	width::Float64
	height::Float64
	objects::Vector{SvgObject}
	styles::Dict{String, Style}
	Svg() = new(0,0, Vector{SvgObject}(), Dict{String, Style}())
	Svg(w,h) = new(w,h, Vector{SvgObject}(), Dict{String, Style}())
end

function Base.write(io::IO, svg::Svg)
	println(io, "<svg width=\"", round(svg.width, digits=2), "\" height=\"", round(svg.height, digits=2), "\">")
	for o in svg.objects
		write(io, o)
	end
	println(io, "</svg>")
end

Base.write(io::IO, s::Style) = print(io, "style=\"", "fill:", s.fill, ";stroke:", s.strokecolor, ";stroke-width:", round(s.strokewidth, digits=2), "\"")

function Base.write(io::IO, p::Polyline)
	print(io, "<polyline points=\"")
	for v in p.points
		print(io, round(v[1], digits=2), ", ", round(v[2], digits=2), " ")
	end
	print(io, "\" ")
	write(io, p.style)
	println(" />")
end

###
end
