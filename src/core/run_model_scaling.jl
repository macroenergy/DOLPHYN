@doc raw"""
    run_model_scaling(EP::Model, mysetup::Dict{String, Any})
    This function is taking a Model type and mysetup Dictionary. The Model is used to do further model scaling. 
    mysetup Dictionary sets up the range with upper target (1e6) and lower target (1e-3).
"""
function run_model_scaling(EP::Model, mysetup::Dict{String, Any})
    scale_constraints!(EP, mysetup["Upper_Target"], mysetup["Lower_Target"])
    return EP
end

@doc raw"""
    scale_constraints!(EP::Model, max_coeff::Float64=1e6, min_coeff::Float64=1e-3)
    This function get all constraints for a Model and pass a ConstraintRef vector to another function for further modifications
"""
function scale_constraints!(EP::Model, max_coeff::Float64=1e6, min_coeff::Float64=1e-3)
    con_list = all_constraints(EP; include_variable_in_set_constraints=false)
    total_number_cts = size(con_list)[1]
    println("$total_number_cts is the total number of constraints")
    @info "$total_number_cts is the total number of constraints"
    fix_cons_count = scale_constraints!(con_list, max_coeff, min_coeff)
    println("how many constraints need to get fixed: ", fix_cons_count)
    @info "how many constraints need to get fixed: $fix_cons_count"
end

@doc raw"""
    scale_constraints!(constraint_list::Vector{ConstraintRef}, max_coeff::Float64=1e6, min_coeff::Float64=1e-3)
    This function will modify constraint objects that need a scaling change
"""
function scale_constraints!(constraint_list::Vector{ConstraintRef}, max_coeff::Float64=1e6, min_coeff::Float64=1e-3)
    action_count = 0
    for con_ref in constraint_list
        con_obj = constraint_object(con_ref)
        coefficients = abs.(append!(con_obj.func.terms.vals, normalized_rhs(con_ref)))
        #coefficients[coefficients .< min_coeff / 100] .= 0 # Set any coefficients less than min_coeff / 100 to zero
        coefficients = coefficients[coefficients .> 0] # Ignore constraints which equal zero
        if length(coefficients) == 0
            continue
        end

        max_ratio = maximum(coefficients) / max_coeff
        min_ratio = min_coeff / minimum(coefficients)

        if max_ratio > 1 && min_ratio < 1
            if min_ratio / max_ratio < 1
                println("Before normalized: ",  con_obj.func.terms)
                @info "Before normalized: $(con_obj.func.terms)"
                println("$max_ratio")
                @info "$max_ratio"
                for (key, val) in con_obj.func.terms
                    set_normalized_coefficient(con_ref, key, val / max_ratio)
                end
                set_normalized_rhs(con_ref, normalized_rhs(con_ref) / max_ratio)
                action_count += 1
                println("After normalized: ", con_obj.func.terms)
                @info "After normalized: $(con_obj.func.terms)"
            end
        elseif min_ratio > 1 && max_ratio < 1
            if max_ratio * min_ratio < 1
                println("Before normalized: ", con_obj.func.terms)
                @info "Before normalized: $(con_obj.func.terms)"
                println(min_ratio)
                @info min_ratio
                for (key, val) in con_obj.func.terms
                    set_normalized_coefficient(con_ref, key, val * min_ratio)
                end
                set_normalized_rhs(con_ref, normalized_rhs(con_ref) * min_ratio)
                action_count += 1
                println("After normalized: ", con_obj.func.terms)
                @info "After normalized: $(con_obj.func.terms)"
            end
        end
    end
    return action_count
end
