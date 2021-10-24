
function hilbert(startPoint, deltaX, stepSize, depth)

	points = Vector{Tuple{Float64, Float64}}()
	push!(points, startPoint)

	east = (d=1)-> push!(points, (points[length(points)][1]+(d*stepSize), points[length(points)][2]))
	west = (d=1)-> push!(points, (points[length(points)][1]-(d*stepSize), points[length(points)][2]))
	north = (d=1)-> push!(points, (points[length(points)][1], points[length(points)][2]-(d*stepSize)))
	south = (d=1)-> push!(points, (points[length(points)][1], points[length(points)][2]+(d*stepSize)))
	
	# depth == 3
	east()
	south()
	west()
	south()
	east(3)
	north()
	west()
	north()
	east(2)

	# depth == 4
	east()
	south()
	west()
	south(2)
	east()
	north()
	east()
	south()
	east()
	north(2)
	west()
	north()
	east(2)

	# depth == 5
	east()
	south()
	west()
	south()
	east()
	south()
	west()
	south()
	east(3)
	north()
	west()
	north()
	east()
	north()
	west()
	north()
	east(2)

	# depth == 6
	east()
	south()
	west()
	south()
	east()
	south()
	west()
	south(2)
	east()
	north()
	east()
	south()
	east()
	north(2)
	west()
	north()
	east()
	north()
	west()
	north()
	east(2)

	points
end


