module svg

function opensvg(io, h::Float64, w::Float64)
	@printf(io, "<svg height=\"%0.2f\" width=\"%0.2f\">\n", w, h)
end

function polyline(fid, pts::Vector{Tuple{Real, Real}}, style::String)
	@printf(fid, "<polyline points=\"")
	for (x,y) in pts
		@printf(fid, "%0.2f, %0,2f ", x, y)
	end
	@printf("\" style=\"%s\" />\n")
end

function blackline(w::Real)
	@sprintf("fill:none;stroke:black;stroke-width:%0.2f", w)
end

function closesvg(io, h::Float64, w::Float64)
	println(io, "</svg>")
end

end
