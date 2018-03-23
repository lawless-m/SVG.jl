module SVG


function open(io, h::Float64, w::Float64)
	@printf(io, "<svg height=\"%0.2f\" width=\"%0.2f\">\n", w, h)
end

function polyline(fid, pts::Vector{Tuple{Real, Real}}, style::String)
	println(fid, "<polyline points=\"")
	for (x,y) in pts
		@printf(fid, "%0.2f, %0.2f ", x, y)
	end
	@printf(fid, "\" style=\"%s\" />\n", style)
end

function blackline(w::Real)
	@sprintf("fill:none;stroke:black;stroke-width:%0.2f", w)
end

function close(io)
	println(io, "</svg>")
end

end
