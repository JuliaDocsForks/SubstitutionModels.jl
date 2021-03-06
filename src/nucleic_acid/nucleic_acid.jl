const _πA(mod) = _πACGT(mod)
const _πC(mod) = _πACGT(mod)
const _πG(mod) = _πACGT(mod)
const _πT(mod) = _πACGT(mod)
const _πACGU(mod) = _πACGT(mod)


_πACGT(mod::NASM) = 0.25

_π(mod::NASM) = SVector(_πA(mod), _πC(mod), _πG(mod), _πT(mod))

_πR(mod::NASM) = _πA(mod) + _πG(mod)

_πY(mod::NASM) = _πT(mod) + _πC(mod)


"""
Generate a Q matrix for a `NucleicAcidSubstitutionModel`, of the form:

\$Q = \\begin{bmatrix}
Q_{A, A} & Q_{A, C} & Q_{A, G} & Q_{A, T} \\\\
Q_{C, A} & Q_{C, C} & Q_{C, G} & Q_{C, T} \\\\
Q_{G, A} & Q_{G, C} & Q_{G, G} & Q_{G, T} \\\\
Q_{T, A} & Q_{T, C} & Q_{T, G} & Q_{T, T} \\end{bmatrix}\$
"""
@inline function Q(mod::NASM)
    α = _α(mod)
    β = _β(mod)
    γ = _γ(mod)
    δ = _δ(mod)
    ϵ = _ϵ(mod)
    η = _η(mod)
    πA = _πA(mod)
    πC = _πC(mod)
    πG = _πG(mod)
    πT = _πT(mod)

    return Qmatrix(-(δ * πC + η * πG + β * πT), δ * πA, η * πA, β * πA,
                   δ * πC, -(δ * πA + ϵ * πG + α * πT), ϵ * πC, α * πC,
                   η * πG, ϵ * πG, -(η * πA + ϵ * πC + γ * πT), γ * πG,
                   β * πT, α * πT, γ * πT, -(β * πA + α * πC + γ * πG))
end


@inline function P_generic(mod::NASM, t::Float64)
    if t < 0.0
        error("t must be positive")
    end
    return exp(Q(mod) * t)
end


function P_generic(mod::NASM, t::Array{Float64})
    if any(t .< 0.0)
        error("t must be positive")
    end
    try
        eig_vals, eig_vecs = eig(Q(mod))
        return [eig_vecs * exp(diagm(eig_vals)*i) * eig_vecs' for i in t]
    catch
        eig_vals, eig_vecs = eig(Array(Q(mod)))
        return [SMatrix(eig_vecs * exp(diagm(eig_vals)*i) * eig_vecs') for i in t]
    end
end


"""
Generate a P matrix for a `NucleicAcidSubstitutionModel`, of the form:

\$P = \\begin{bmatrix}
P_{A, A} & P_{A, C} & P_{A, G} & P_{A, T} \\\\
P_{C, A} & P_{C, C} & P_{C, G} & P_{C, T} \\\\
P_{G, A} & P_{G, C} & P_{G, G} & P_{G, T} \\\\
P_{T, A} & P_{T, C} & P_{T, G} & P_{T, T} \\end{bmatrix}\$

for specified time
"""
P(mod::NASM, t) = P_generic(mod, t)
