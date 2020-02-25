
# Type mismatch argument --------------------------------------
modify_namelist("inst/user_namelist_cond1.json")
gen_WGN_ts(nyears = 10, replicates = 5)


# Infeasible argument -----------------------------------------
modify_namelist("inst/user_namelist_cond2.json")
gen_WGN_ts(nyears = 10, replicates = 5)


# Argument length mismatch ------------------------------------
modify_namelist("inst/user_namelist_cond3.json")
gen_WGN_ts(nyears = 10, replicates = 5)


# Two problems -----------------------------------------------
modify_namelist("inst/user_namelist_cond3.json")
gen_WGN_ts(nyears = 10.5, replicates = 5)
