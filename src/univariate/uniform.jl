immutable Uniform <: ContinuousUnivariateDistribution
    a::Float64
    b::Float64
    function Uniform(a::Real, b::Real)
	a < b || error("a < b required for range [a, b]")
	new(float64(a), float64(b))
    end
    Uniform() = new(0.0, 1.0)
end

## Support
insupport(d::Uniform, x::Real) = d.a <= x <= d.b

isupperbounded(::Union(Uniform, Type{Uniform})) = true
islowerbounded(::Union(Uniform, Type{Uniform})) = true
isbounded(::Union(Uniform, Type{Uniform})) = true

minimum(d::Uniform) = d.a
maximum(d::Uniform) = d.b
insupport(d::Uniform, x::Real) = d.a <= x <= d.b

## Properties
mean(d::Uniform) = (d.a + d.b) / 2.0

median(d::Uniform) = (d.a + d.b) / 2.0

mode(d::Uniform) = d.a
modes(d::Uniform) = error("The uniform distribution has no modes")

function var(d::Uniform)
    w = d.b - d.a
    w * w / 12.0
end

skewness(d::Uniform) = 0.0
kurtosis(d::Uniform) = -1.2

entropy(d::Uniform) = log(d.b - d.a)

## Functions
pdf(d::Uniform, x::Real) = insupport(d,x) ? 1/(d.b-d.a) : 0.0
logpdf(d::Uniform, x::Real) = insupport(d,x) ? -log(d.b-d.a) : -Inf 

function cdf(d::Uniform, q::Real) 
    if isnan(q)
        return NaN
    elseif q <= d.a
        return 0.0
    elseif q >= d.b
        return 1.0
    end
    (q-d.a)/(d.b-d.a)
end
function ccdf(d::Uniform, q::Real) 
    if isnan(q)
        return NaN
    elseif q <= d.a
        return 1.0
    elseif q >= d.b
        return 0.0
    end
    (d.b-q)/(d.b-d.a)
end

quantile(d::Uniform, p::Real) = @checkquantile p d.a+p*(d.b-d.a)
cquantile(d::Uniform, p::Real) = @checkquantile p d.b+p*(d.a-d.b)


function mgf(d::Uniform, t::Real)
	a, b = d.a, d.b
	return (exp(t * b) - exp(t * a)) / (t * (b - a))
end

function cf(d::Uniform, t::Real)
	a, b = d.a, d.b
	return (exp(im * t * b) - exp(im * t * a)) / (im * t * (b - a))
end

## Sampling
rand(d::Uniform) = d.a + (d.b - d.a) * rand()

## Fitting
function fit_mle{T <: Real}(::Type{Uniform}, x::Vector{T})
    if isempty(x)
        throw(ArgumentError("x cannot be empty."))
    end

    xmin = xmax = x[1]
    for i = 2:length(x)
        xi = x[i]
        if xi < xmin
            xmin = xi
        elseif xi > xmax
            xmax = xi
        end
    end

    Uniform(xmin, xmax)
end
