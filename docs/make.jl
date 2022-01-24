using Documenter
using SVG
using Dates


makedocs(
    modules = [SVG],
    sitename="SVG.jl", 
    authors = "Matt Lawless",
    format = Documenter.HTML(),
)

deploydocs(
    repo = "github.com/lawless-m/SVG.jl.git", 
    devbranch = "main",
    push_preview = true,
)
