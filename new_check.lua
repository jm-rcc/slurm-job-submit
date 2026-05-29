local utils = dofile("/etc/slurm/job_submit/lib/utils.lua")

return function(job_desc)
    return slurm.SUCCESS
end
