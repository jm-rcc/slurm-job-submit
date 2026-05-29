--[[

    job_submit.lua
    Slurm job submission script

    This script should be copied into a file name "job_submit.lua"
    in the same directory as the Slurm configuration file, slurm.conf.

--]]

--# selene: allow(undefined_variable)
--# selene: allow(unused_variable)
-- luacheck: ignore
-- stylua: ignore start

-- Helper function (from edf-hpc) --
function get_gpu_count(str)
   -- Get GPU count from a given string
   -- str: "gres/gpu:N" or "gres/gpu:model:N"

   -- Remove the "gres/" prefix if present
   local value = str:gsub("^gres/", "")

   -- Try to match the "gpu:N" format
   local count = string.match(value, "^gpu:(%d+)$")

   -- If not matched, try to match the "gpu:model:N" format
   if not count then
      _, count = string.match(value, "^gpu:(%w+):(%d+)$")
   end

   -- Validate that count is a positive integer
   if count and tonumber(count) and tonumber(count) > 0 then
      return tonumber(count)
   end

   return nil
end


-- CHECK: GPU QOS must not be wasted on CPU-only jobs
local function check_gpu_qos_needs_gpu(job_desc)

   local gpu_partition = "gpu"
   if job_desc.qos == gpu_partition then

       local count = nil
       -- Check for --gres=gpu:N or --gres=gpu:model:N requests.
       if job_desc.gres and string.find(job_desc.gres, "gpu") then
           count = get_gpu_count(job_desc.gres)
       -- Check for --gpus=N requests (tres_per_job can be used for this purpose)
       elseif job_desc.tres_per_job then
           count = get_gpu_count(job_desc.tres_per_job)
       else
           slurm.user_msg("QOS '%s' is reserved for GPU jobs but no GPU was requested. ", job_desc.qos)           
           -- return false
           return true
       end

       if not count then
           slurm.user_msg("QOS '%s' is reserved for GPU jobs but no GPU was requested. ", job_desc.qos)
           -- return false
           return true
       end

   end

   return true
end

-- Perform each of the job check functions in order --
function check_job(job_desc)

    -- List of check functions --
    local checks = {
        check_gpu_qos_needs_gpu,
    }

    -- Perform each check in order. If any check fails, return failure. --
    for _, check in ipairs(checks) do
        local rc = check(job_desc)
        if rc == false then
            -- stop at first failure --
            return false   
        end
    end

    return true
end

-- SLURM API FUNCTION --
function slurm_job_submit(job_desc, part_list, submit_uid)
    -- Check the job. If any check fails, don't submit. --
    local check_result = check_job(job_desc)
    if check_result == false then
        return slurm.ERROR
    end
    return slurm.SUCCESS
end

-- SLURM API FUNCTION --
function slurm_job_modify(job_desc, job_rec, part_list, modify_uid)
    -- Check the job. If any check fails, don't submit. --
    local check_result = check_job(job_desc)    
    if check_result == false then
        return slurm.ERROR
    end
    return slurm.SUCCESS
end

-- MESSAGE WHEN SCRIPT LOADS (slurmctrld) --
slurm.log_info("Parsed job_submit.lua successfully.")
return slurm.SUCCESS

-- stylua: ignore end
