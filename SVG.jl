module SVG

using Printf

function open(fid, h::Number, w::Number)
	@printf(fid, "<svg height=\"%0.2f\" width=\"%0.2f\">\n", h, w)
end

function polyline(fid, pts::Vector{Tuple{Float64, Float64}}, style::String)
	println(fid, "<polyline points=\"")
	for (x,y) in pts
		@printf(fid, "%0.2f, %0.2f ", x, y)
	end
	@printf(fid, "\" style=\"%s\" />\n", style)
end

function blackline(w::Number)
	style("none", "black", w)
end

function style(fill::String, strokecolor::String, strokewidth::Number)
	@sprintf("fill:%s;stroke:%s;stroke-width:%0.2f", fill, strokecolor, strokewidth)
end

function close(io)
	println(io, "</svg>")
end

end
