--[[

    job_submit.lua
    Slurm job submission script

--]]

--# selene: allow(undefined_variable)
--# selene: allow(unused_variable)
-- luacheck: ignore
-- stylua: ignore start

-- MESSAGE WHEN SCRIPT LOADS (on scontrol reconfigure) --
slurm.log_info("Loading job_submit.lua...")

-- SLURM API FUNCTION --
function slurm_job_submit(job_desc, part_list, submit_uid)
    return slurm.SUCCESS
end

-- SLURM API FUNCTION --
function slurm_job_modify(job_desc, job_rec, part_list, modify_uid)
    return slurm.SUCCESS
end

-- MESSAGE WHEN SCRIPT LOADS (on scontrol reconfigure) --
slurm.log_info("Loaded job_submit.lua successfully.")

-- stylua: ignore end
