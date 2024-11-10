# adapted from https://juliadatascience.io/julia_accomplish
f(x) = x + 3
g(x) = f(x) * 2


# adds 3 to input
@code_llvm f(3)
# define i64 @julia_f_49640(i64 signext %"x::Int64") #0 {
# top:
# ; ┌ @ int.jl:87 within `+`
#    %0 = add i64 %"x::Int64", 3
#    ret i64 %0
# ; └
# }

# doubles via bit shifting, then adds 6 (2 steps)
@code_llvm g(3)
# define i64 @julia_g_49636(i64 signext %"x::Int64") #0 {
# top:
# ; ┌ @ int.jl:88 within `*`
#    %0 = shl i64 %"x::Int64", 1
#    %1 = add i64 %0, 6
#    ret i64 %1
# ; └
# }

# when not optimized, composition is performed as written:
# first, the function adds three, then it multiples by two numerically
# compared to optimized: 1) 4 steps vs 2 steps. 2) does not optimize multiplication
@code_llvm optimize=false g(3)
# define i64 @julia_g_49632(i64 signext %"x::Int64") #0 {
# top:
#   %pgcstack = call ptr @julia.get_pgcstack()
#   %current_task = getelementptr inbounds ptr, ptr %pgcstack, i64 -14
#   %world_age = getelementptr inbounds i64, ptr %current_task, i64 15
#   %x = alloca i64, align 8
#   store i64 %"x::Int64", ptr %x, align 8
# ; ┌ @ c:\projects\julia-start\code_llvm.jl:1 within `f`
# ; │┌ @ int.jl:87 within `+`
#     %"*Core.Intrinsics.add_int#49634" = load ptr, ptr @"*Core.Intrinsics.add_int#49634", align 8
#     %0 = getelementptr inbounds ptr, ptr %"*Core.Intrinsics.add_int#49634", i64 0
#     %1 = add i64 %"x::Int64", 3
# ; └└
# ; ┌ @ int.jl:88 within `*`
#    %"*Core.Intrinsics.mul_int#49635" = load ptr, ptr @"*Core.Intrinsics.mul_int#49635", align 8
#    %2 = getelementptr inbounds ptr, ptr %"*Core.Intrinsics.mul_int#49635", i64 0
#    %3 = mul i64 %1, 2
#    ret i64 %3
# ; └
# }
