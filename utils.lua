-- Shared utilities available to all check modules

local M = {}

function M.reject(job_desc, msg)
    slurm.log_user("job_submit: %s", msg)
    slurm.log_info("job_submit REJECT uid=%u: %s", job_desc.user_id, msg)
    job_desc.comment = msg:sub(1, 512)   -- guard against comment truncation
    return slurm.ERROR
end

function M.log_info(msg)
    slurm.log_info("job_submit: %s", msg)
end

-- Extract total GPU count from a GRES string e.g. "gpu:a100:2,gpu:1"
function M.count_gpus(gres_str)
    if not gres_str or gres_str == "" then return 0 end
    local total = 0
    for entry in gres_str:gmatch("[^,]+") do
        if entry:match("^gpu") then
            local parts = {}
            for p in entry:gmatch("[^:]+") do table.insert(parts, p) end
            -- Count is the last field only if it is numeric
            local last  = parts[#parts]
            local count = tonumber(last)
            -- If last field is not numeric it is a model name with no count → 1
            total = total + (count or 1)
        end
    end
    return total
end

-- Derive total CPUs from the combination of fields Slurm populates
function M.total_cpus(job_desc)
    local cpus_per_task = job_desc.cpus_per_task or 1
    local num_tasks     = job_desc.num_tasks     or 1
    return cpus_per_task * num_tasks
end

-- Return true if the GRES or TRES string contains a GPU request
function M.requests_gpu(job_desc)
    local function has_gpu(s) return s and s:find("gpu") ~= nil end
    return has_gpu(job_desc.gres) or has_gpu(job_desc.tres_req_str)
end

return M
