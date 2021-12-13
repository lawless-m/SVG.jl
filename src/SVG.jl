module SVG

export Style, Svg, Polyline, Circle, Line, write, translate, bounds

dp(n; digits=2) = round(n; digits)

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
	objects::Vector{SvgObject}
	Svg() = new(Vector{SvgObject}())
	Svg(objs) = new(objs)
end

function bounds(svg::Svg)
	xmin, xmax, ymin, ymax = Inf, -Inf, Inf, -Inf
	for b in map(bounds, svg.objects)
		if b.xmin < xmin
			xmin = b.xmin
		end
		if b.xmax > xmax
			xmax = b.xmax
		end
		if b.ymin < ymin 
			ymin = b.ymin
		end
		if b.ymax > ymax
			ymax = b.ymax
		end
	end
	xmin, ymin = max(0,xmin), max(0,ymin)
	(;xmin, xmax, ymin, ymax)
end

Base.write(fn::String, svg::Svg, width, height; viewbox="", inhtml=false, digits=2, objwrite_fn=write_objs) = open(fn, "w+") do io write(io, svg, width, height; viewbox, inhtml, digits, objwrite_fn) end

write_objs(io::IO, svg::Svg) = foreach(o->write(io, o), svg.objects)

function Base.write(io::IO, svg::Svg, width, height; viewbox="", inhtml=false, digits=2, objwrite_fn=write_objs)
	if inhtml
		println(io, "<html><body><div>")
	end
	if viewbox == ""
		viewbox = ""
	else
		viewbox = " viewBox=\"$viewbox\""
	end
	println(io, """<svg width="$width" height="$height"$viewbox>""")
	objwrite_fn(io, svg)
	println(io, "</svg>")
	if inhtml
		println(io, "</div></body></html>")
	end
end

Base.write(io::IO, s::Style) = print(io, "style=\"", "fill:", s.fill, ";stroke:", s.strokecolor, ";stroke-width:", dp(s.strokewidth), "\"")

function Base.write(io::IO, p::Polyline)
	print(io, "<polyline points=\"")
	foreach(i->print(io, p.xs[i], ",", p.ys[i], " "), 1:length(p.xs))
	print(io, "\" ")
	write(io, p.style)
	println(io, " />")
end

bounds(p::Polyline) = (xmin=minimum(p.xs), xmax=maximum(p.xs), ymin=minimum(p.ys), ymax=maximum(p.ys))

function Base.write(io::IO, L::Line)
	print(io, "<line x1=\"", L.x1, "\" y1=\"", L.y1, "\" x2=\"", L.x2, "\" y2=\"", L.y2, "\" ")
	write(io, L.style)
	println(io, " />")
end

bounds(l::Line) = (xmin=min(l.x1,l.x2), xmax=max(l.x1,l.x2), ymin=min(l.y1,l.y2), ymax=max(l.y1,l.y2))

function Base.write(io::IO, c::Circle)
	print(io, "<circle cx=\"", c.x, "\" cy=\"", c.y, "\" r=\"", c.r, "\" ")
	write(io, c.s)
	println(io, " />")
end

points2circles(xs, ys; r=1) = map(i->Circle(xs[i], ys[i], r), 1:length(xs))

bounds(c::Circle) = (xmin=c.x-c.r, xmax=c.x+c.r, ymin=c.y-c.r, ymax=c.y+c.r)

#helper
translate(points::Vector, delta) = map(p->p+delta, points)

###
end

