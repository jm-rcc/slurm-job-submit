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

-- LOADING FUNCTION FOR CHECK FUNCTIONS
local function load_check(name)
    local path = "/etc/slurm/job_submit/checks/" .. name .. ".lua"
    local fn, err = loadfile(path)
    if not fn then
        slurm.log_info("job_submit: failed to load check '%s': %s", name, err)
        -- Use a default function if loading fails
        return function() return slurm.SUCCESS end  
    end
    return fn()
end

-- CHECK FUNCTIONS - ADD OR REMOVE CHECKS HERE
local checks = {
}

-- RUN ALL OF THE CHECKS AND RETURN SUCCESS IF THEY ALL PASS
local function run_checks(job_desc)
    for _, check in ipairs(checks) do
        local rc = check(job_desc)
        if rc ~= slurm.SUCCESS then
            return rc
        end
    end
    return slurm.SUCCESS
end

-- SLURM API FUNCTION --
function slurm_job_submit(job_desc, part_list, submit_uid)
    if submit_uid == 0 then return slurm.SUCCESS end
    return run_checks(job_desc)
end

-- SLURM API FUNCTION --
function slurm_job_modify(job_desc, job_rec, part_list, modify_uid)
    return slurm.SUCCESS
end

-- MESSAGE WHEN SCRIPT LOADS (on scontrol reconfigure) --
slurm.log_info("Loaded job_submit.lua successfully.")

-- stylua: ignore end
