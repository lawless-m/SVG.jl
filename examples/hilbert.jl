
function hilbert(startPoint, deltaX, stepSize, depth)

	points = Vector{Tuple{Float64, Float64}}()
	push!(points, startPoint)

	e = ()-> push!(points, (points[length(points)][1]+(d*stepSize), points[length(points)][2]))
	w = ()-> push!(points, (points[length(points)][1]-(d*stepSize), points[length(points)][2]))
	n = ()-> push!(points, (points[length(points)][1], points[length(points)][2]-(d*stepSize)))
	s = ()-> push!(points, (points[length(points)][1], points[length(points)][2]+(d*stepSize)))

	esws = e |> s |> w |> s

	function walk(a)
		for wlk in a
			wlk()
		end
	end

	
	# depth == 3
	walk(hcat([esws], [e e e], [n w n e]))
	east()

	# depth == 4
	walk(hcat([e s w s], [s e n e s e n], [n w n e]))
	east()

	# depth == 5
	walk(hcat([:e :s :w :s], [:e :s :w :s], [:e :e :e], [:n :w :n :e], [:n :w :n :e]))
	east()

	# depth == 6
	walk(hcat([:e :s :w :s], [:e :s :w :s], [:s :e :n :e :s :e :n], [:n :w :n :e], [:n :w :n :e]))
	east()

	# depth == 7
	walk(hcat([:e :s :w :s], [:e :s :w :s], [:e :s :w :s], [:e :e :e], [:n :w :n :e], [:n :w :n :e], [:n :w :n :e]))
	east()

	# depth == 8
	walk(hcat([:e :s :w :s], [:e :s :w :s], [:e :s :w :s], [:s :e :n :e :s :e :n], [:n :w :n :e], [:n :w :n :e], [:n :w :n :e]))
	east()


	points
end


