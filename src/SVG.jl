module SVG

export Inline, Class, Svg, Polyline, Circle, Line, write, bounds, bounds_viewbox, scaled, points2circles

import Base.==

dp(n; digits=2) = round(n; digits)

abstract type SvgObject end

abstract type Style end

"""
	Inline
Inline style object
# Properties
- `attribs` Dict of CSS attributes
# Constructor
	Inline(;fill="none", stroke="black", stroke_width=1)
All keyword arguments
"""
struct Inline <: Style
	attribs 
	function Inline(pairs=[];fill="none", stroke="black", stroke_width=1)
		attribs = Dict()
		attribs["fill"] = fill
		attribs["stroke"] = stroke
		attribs["stroke-width"] = stroke_width
		for (k,v) in pairs
			attribs[k] = v
		end
		new(attribs)
	end
end

"""
	Class
CSS class name Object
# Constructor
	Class(class::String)
"""
struct Class <: Style
	class::String
end

"""
	Polyline
Polyline object
# Properties
- `xs` Vector of X coordinates, one per vertex
- `ys` Vector of Y coordinates, one per vertex
# Constructors
Quite the choice. 
- Construct with separate vectors or vectors of 2d points. 
- Supply an optional transformation function `fx`, `fy`, `fxy`
- Or empty or with pre-allocated vectors of `xs`/`ys`
- Supply `Style` using kwarg
```
Polyline(; style::Style=Inline())
Polyline(npoints::Int; style::Style=Inline())
Polyline(xs::Vector, ys::Vector; style::Style=Inline()) 
Polyline(xs::Vector, ys::Vector, fx::Function, fy::Function; style::Style=Inline()) 
Polyline(xys::Vector; style::Style=Inline()) 
Polyline(xys::Vector, fxy::Function; style::Style=Inline()) 
Polyline(xys::Vector, fx::Function, fy::Function; style::Style=Inline())
```
"""
struct Polyline <: SvgObject
	xs
	ys 
	style::Style
	Polyline(; style::Style=Inline()) = new(Vector{Float64}(), Vector{Float64}(), style)
	Polyline(npoints::Int; style::Style=Inline()) = new(Vector{Float64}(undef, npoints), Vector{Float64}(undef, npoints), style)
	Polyline(xs::Vector, ys::Vector; style::Style=Inline()) = new(xs, ys, style)
	Polyline(xs::Vector, ys::Vector, fx::Function, fy::Function; style::Style=Inline()) = Polyline(map(fx, xs), map(fy, ys); style)
	Polyline(xys::Vector; style::Style=Inline()) = Polyline(map(xy->xy[1], xys), map(xy->xy[2], xys); style)
	Polyline(xys::Vector, fxy::Function; style::Style=Inline()) = Polyline(map(xy->fxy(xy), xys); style)
	Polyline(xys::Vector, fx::Function, fy::Function; style::Style=Inline()) = Polyline(map(xy->fx(xy[1]), xys), map(xy->fy(xy[2]), xys); style)
end

==(p1::Polyline, p2::Polyline) = p1.xs == p2.xs && p1.ys == p2.ys && p1.style.attribs == p2.style.attribs

scaled(p::Polyline, fx, fy) = Polyline(p.xs, p.ys, fx, fy; style=p.style)

"""
	Line
# Properties
- `x1`, `y1` `x2`, `y2` - Endpoints of the line
- `style` - Style object for this line
# Constructor
	Line(x1, y1, x2, y2; style::Style=Inline())
"""
struct Line <: SvgObject
	x1
	y1
	x2
	y2
	style::Style
	Line(x1, y1, x2, y2; style::Style=Inline()) = new(x1, y1, x2, y2, style)
end

scaled(l::Line, fx, fy) = Line(fx(l.x1), fy(l.y1), fx(l.x2), fy(l.y2); style=l.style)

"""
	Circle
Circle object
# Properties
- `x`, `y`, `r` - position and radius
- `style` = Style object
Radius is invariant under the module supplied scaling operations
"""
struct Circle <: SvgObject
	x
	y
	r
	style::Style
	Circle(x, y, r; style::Style=Inline()) = new(x, y, r, style)
end

scaled(c::Circle, fx, fy) = Circle(fx(c.x), fy(c.y), c.r; style=c.style)

"""
	Svg
Svg object
# Properties
- `objects` - Vector of SVG objects
# Constructors
Call either empty or with Vector of existing objects
- `Svg()`
- `Svg(objs::SvgObject)`
"""
struct Svg
	objects::Vector{SvgObject}
	Svg() = new(Vector{SvgObject}())
	Svg(objs) = new(objs)
end
"""
	scaled(s::Svg, w, h; digits, flip_y)
	scaled(s::Svg, fx, fy)
	scaled(s::SvgObject, fx, fy)
Scale either the whole Svg or individual Objects
- `s` either the whole Svg or individual objects
- `fx`, `fy` - functions to scale the positional co-ordinates
- `w`, `h` - scale the entire Svg up to the smallest of `w` / `h` and maintain aspect ratio
- `digits::Int` - round to this many digits
- `flip_y::Bool` - flip vertically
"""
scaled(s::Svg, fx::Function, fy::Function) = Svg(map(o->scaled(o, fx, fy), s.objects))
function scaled(svg, width::Real, height::Real; flip_y=false, digits=2)
    xmin, ymin, xmax, ymax = bounds(svg)
    xmx = xmax - xmin
    ymx = ymax - ymin
    scale = min(width, height) / min(xmx, ymx)
    fx = x -> round(scale * (x - xmin); digits)
    fy = y -> round(flip_y ? height - scale * (y - ymin) : scale * (y - ymin); digits)
	scaled(svg, fx, fy)
end

"""
	bounds(svg::Svg)	
	bounds(svg::SvgObject)
Return the bounding box of the entire `Svg` or an individual `SvgObject`
# Returns
NamedTuple(xmin, ymin, xmax, ymax)
"""
function bounds(svg::Svg)
	xmin, ymin, xmax, ymax = Inf, Inf, -Inf, -Inf
	for b in map(bounds, svg.objects)
		if b.xmin < xmin
			xmin = b.xmin
		end
		if b.ymin < ymin 
			ymin = b.ymin
		end
		if b.xmax > xmax
			xmax = b.xmax
		end
		if b.ymax > ymax
			ymax = b.ymax
		end
	end
	(;xmin, ymin, xmax, ymax)
end

"""
	bounds_viewbox(svg::Svg)
	bounds_viewbox(bounds::NamedTuple)
Create a viewbox string using either the Svg or a set of bounds
"""
bounds_viewbox(svg::Svg) = bounds_viewbox(bounds(svg))
bounds_viewbox(bounds::NamedTuple) = "$(bounds.xmin) $(bounds.ymin) $(bounds.xmax) $(bounds.ymax)"

"""
	write(fn::String, svg::Svg, width, height; viewbox="", inhtml=false, digits=2, objwrite_fn=write_objs)
	write(io::IO, svg::Svg, width, height; viewbox="", inhtml=false, digits=2, objwrite_fn=write_objs)
write the Svg to a file or IO object. 
# Arguments
- `fn` - write to filename
- `io` - write to IO Object
- `svg` - the Svg to write
- `width`, `height` - the width / height of the SVG object to supply
- `viewbox` - specify a particular viewbox: "xmin ymin xmax ymax"
- `inhtml` - Boolean flag whether to wrap the SVG in an HTML document for viewing in a browser.
- `digits` - round all SVG Object co-ordinates to this many digits
- `objwrite_fn` - a callback so the caller can modify the objects as they are written
"""
Base.write(fn::String, svg::Svg, width, height; viewbox="", inhtml=false, stylesheet="", digits=2, objwrite_fn=write_objs) = open(fn, "w+") do io write(io, svg, width, height; viewbox, inhtml, stylesheet, digits, objwrite_fn) end

write_objs(io::IO, svg::Svg) = foreach(o->write(io, o), svg.objects)

function Base.write(io::IO, svg::Svg, width, height; viewbox="", inhtml=false, stylesheet="", digits=2, objwrite_fn=write_objs)
	open_html(io; inhtml)
	open_svg(io, width, height; viewbox, stylesheet)
	objwrite_fn(io, svg)
	close_svg(io)
	close_html(io; inhtml)
end

function open_svg(io, width, height; viewbox="", stylesheet="")
	if viewbox != ""
		viewbox = " viewBox=\"$viewbox\""
	end
	println(io, """<svg width="$width" height="$height"$viewbox xmlns="http://www.w3.org/2000/svg">""")
	if stylesheet != ""
		println(io, "<style>\n@import url($(stylesheet).css)\n</style>")
	end
end
close_svg(io) = println(io, "</svg>")
open_html(io; inhtml) = if inhtml println(io, "<html><body><div>") end
close_html(io; inhtml) = if inhtml println(io, "</div></body></html>") end

function Base.write(io::IO, s::Inline)
	print(io, "style=\"")
	for (k,v) in s.attribs
		print(io, "$k:$v; ")
	end
	print(io, "\"")
end
Base.write(io::IO, s::Class) = print(io, "class=\"$(s.class)\"")

function Base.write(io::IO, p::Polyline)
	print(io, "<polyline points=\"")
	foreach(i->print(io, p.xs[i], ",", p.ys[i], " "), 1:length(p.xs))
	print(io, "\" ")
	write(io, p.style)
	println(io, " />")
end

bounds(p::Polyline) = (xmin=minimum(p.xs), ymin=minimum(p.ys), xmax=maximum(p.xs), ymax=maximum(p.ys))

function Base.write(io::IO, L::Line)
	print(io, "<line x1=\"", L.x1, "\" y1=\"", L.y1, "\" x2=\"", L.x2, "\" y2=\"", L.y2, "\" ")
	write(io, L.style)
	println(io, " />")
end

bounds(l::Line) = (xmin=min(l.x1,l.x2), ymin=min(l.y1,l.y2), xmax=max(l.x1,l.x2), ymax=max(l.y1,l.y2))

function Base.write(io::IO, c::Circle)
	print(io, "<circle cx=\"", c.x, "\" cy=\"", c.y, "\" r=\"", c.r, "\" ")
	write(io, c.style)
	println(io, " />")
end

"""
	points2circles(xs, ys, r::Real)
	points2circles(xys, r::Real)
	points2circles(xs, ys, rs::Vector{Real})
	points2circles(xys, rs::Vector{Real})
Helper function to create a collection of points of a given radius to a collection of Circle objects
# Arguments
- `xs`, `ys` Vectors or x/y corrdinates
- `xys` Vector of 2D points
- `r` Radius
- `rs` Vector of Radii
"""
points2circles(xs, ys, r::Real=1) = map(i->Circle(xs[i], ys[i], r), 1:length(xs))
points2circles(xs, ys, rs::Vector{Real}) = map(i->Circle(xs[i], ys[i], r[i]), 1:length(xs))
points2circles(xys, r::Real=1) = map(i->Circle(xys[i][1], xys[i][2], r), 1:length(xys))
points2circles(xys, rs::Vector{Real}) = map(i->Circle(xys[i][1], xys[i][2], r[i]), 1:length(xys))

bounds(c::Circle) = (xmin=c.x-c.r, ymin=c.y-c.r, xmax=c.x+c.r, ymax=c.y+c.r)

###
end

