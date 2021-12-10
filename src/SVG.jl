module SVG

export Style, Svg, Polyline, Circle, Line, write, scale, scale_fn, translate, bounds

dp(n; digits=2) = round(n; digits)

abstract type SvgObject end

struct Style
	fill::String
	strokecolor::String
	strokewidth::Float64
	Style(;fill="none", strokecolor="black", strokewidth=1) = new(fill, strokecolor, strokewidth)
end

function scale_fn(ptop, pmax, pmin)
	scale = ptop / (pmax - pmin)
	n -> scale * (n - pmin)
end

struct Polyline <: SvgObject
	xs
	ys 
	style::Style
	Polyline(; style::Style=Style()) = new(Vector{Float64}(), Vector{Float64}(), style)
	Polyline(npoints::Int; style::Style=Style()) = new(Vector{Float64}(undef, npoints), Vector{Float64}(undef, npoints), style)
	Polyline(xs, ys; style::Style=Style()) = new(xs, ys, style)
end
scale(p::Polyline, scalefn) = Polyline(map(scalefn, p.xs), map(scalefn, p.ys); p.style)

struct Line <: SvgObject
	x1
	y1
	x2
	y2
	style::Style
	Line(x1, y1, x2, y2; style::Style=Style()) = new(x1, y1, x2, y2, style)
end
scale(l::Line, scalefn) = Line(scalefn(l.x1), scalefn(l.y1), scalefn(l.x2), scalefn(l.y2), style=l.style)

struct Circle <: SvgObject
	x
	y
	r
	s::Style
	Circle(x, y, r; style::Style=Style()) = new(x, y, r, style)
end

scale(c::Circle, scalefn) = Circle(scalefn(c.x), scalefn(c.y), scalefn(0) - scalefn(c.r), style=c.s)

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

bounds(p::Polyline) = (xmin=minimum(p.xs), xmax=maximum(p.xs), ymin=minimum(p.ys), ymax=maximum(p.ys))

function Base.write(io::IO, svg::Svg, L::Line; digits=2)
	print(io, "<line x1=\"", dp(L.x1; digits), "\" y1=\"", dp(svg.height-L.y1; digits), "\" x2=\"", dp(L.x2; digits), "\" y2=\"", dp(svg.height-L.y2; digits), "\" ")
	write(io, L.style)
	println(io, " />")
end

bounds(l::Line) = (xmin=min(l.x1,l.x2), xmax=max(l.x1,l.x2), ymin=min(l.y1,l.y2), ymax=max(l.y1,l.y2))

function Base.write(io::IO, svg::Svg, c::Circle; digits=2)
	print(io, "<circle cx=\"", dp(c.x; digits), "\" cy=\"", dp(svg.height-c.y; digits), "\" r=\"", dp(c.r; digits), "\" ")
	write(io, c.s)
	println(io, " />")
end

points2circles(xs, ys; r=1) = map(i->Circle(xs[i], ys[i], r), 1:length(xs))

bounds(c::Circle) = (xmin=c.x-c.r, xmax=c.x+c.r, ymin=c.y-c.r, ymax=c.y+c.r)

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
	(;xmin, xmax, ymin, ymax)
end

scale(points::Vector, ptop::Float64) = map(scale_fn(ptop, maximum(points), minimum(points)), points)
scale(points::Vector, fn::Function) = map(fn, points)

#helper
translate(points::Vector, delta) = map(p->p+delta, points)


###
end

