module Points

# Points are Tuple{Float64, Float64}

export bounding_box, scale_points, translate_points, toFloat64

function bounding_box(points) 
	r = [Inf, -Inf, Inf, -Inf]
	for p in points
		r[1] = min(p[1], r[1])
		r[2] = max(p[1], r[2])
		r[3] = min(p[2], r[3])
		r[4] = max(p[2], r[4])
	end
	r
end

function scale_points(points, xmax, ymax)
	
	function scalefn(low, high, highest) 
		r = high - low
		scale = highest / r
		return n -> scale * (n-low)
	end
	
	bbx = bounding_box(points)	
	scalep(p) = (scalefn(bbx[1], bbx[2], xmax)(p[1]), scalefn(bbx[3], bbx[4], ymax)(p[2]))
	
	map(scalep, points)
end

function translate_points(points, xdelta, ydelta)
	map(p->(p[1]+xdelta, p[2]+ydelta), points)
end

function toFloat64(points)
	map(p->(Float64(p[1]), Float64(p[2])), points)
end
###
end