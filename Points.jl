module Points

# Points are vectors of co-ordinates, callers job to make sure they are the same length

export bounding_box, scale_points, translate_points, toFloat64


function scale(points, ptop)
	pmin, pmax = minimum(points), maximum(points)
	scale = ptop / (pmax - pmin)
	map(n -> scale * (n-pmin), points)
end

translate_points(points, delta) = map(p->p+xdelta, points)
toFloat64(points) = map(Float64, points)


###
end