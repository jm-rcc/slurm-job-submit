
-- checks/gpu_cpu_ratio.lua
local utils = dofile("/etc/slurm/job_submit/lib/utils.lua")

-- THE CHECK FUNCTION
return function(job_desc)

    -- IF JOB_DESC DOESN'T REQUIRE A GPU, THEN WE DON'T NEED THIS CHECK
    local num_gpus = parse_gpu_count(job_desc.gres)
    if num_gpus == 0 then 
        return slurm.SUCCESS 
    end    

    -- Quota Table
    local gpu_node_quotas = {
        ["bun003"] = { mem_per_gpu =  700000, cpu_per_gpu = 86 },
        ["bun004"] = { mem_per_gpu =  180000, cpu_per_gpu = 22 },
        ["bun005"] = { mem_per_gpu =  180000, cpu_per_gpu = 22 },
        ["bun068"] = { mem_per_gpu = 1000000, cpu_per_gpu = 96 },
        ["bun071"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun072"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun073"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun074"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun075"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun076"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun116"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun117"] = { mem_per_gpu =  250000, cpu_per_gpu = 48 },
        ["bun118"] = { mem_per_gpu =  250000, cpu_per_gpu = 48 },
        ["bun119"] = { mem_per_gpu =  250000, cpu_per_gpu = 48 },
        ["bun120"] = { mem_per_gpu =  250000, cpu_per_gpu = 48 },
        ["bun077"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun078"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun079"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun080"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun081"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },
        ["bun082"] = { mem_per_gpu =  700000, cpu_per_gpu = 64 },    
        ["bun124"] = { mem_per_gpu =  250000, cpu_per_gpu = 64 },
        ["bun125"] = { mem_per_gpu =  250000, cpu_per_gpu = 64 },
        ["bun121"] = { mem_per_gpu =   64000, cpu_per_gpu = 16 },
        ["bun122"] = { mem_per_gpu =   64000, cpu_per_gpu = 16 },
        ["bun123"] = { mem_per_gpu =   64000, cpu_per_gpu = 16 },
        ["bun001"] = { mem_per_gpu =  250000, cpu_per_gpu = 96 },
        ["bun002"] = { mem_per_gpu =  250000, cpu_per_gpu = 96 },
        ["bun070"] = { mem_per_gpu =  190000, cpu_per_gpu = 32 },
        ["bun144"] = { mem_per_gpu =  250000, cpu_per_gpu = 16 },
        ["bun145"] = { mem_per_gpu =  250000, cpu_per_gpu = 16 },
    }

    --local policy   = resolve_policy(job_desc.partition)
    local req_cpus = (job_desc.cpus_per_task or 1)
                       * (job_desc.num_tasks or 1)
    local req_mem  = decode_mem_mb(job_desc.pn_min_memory, req_cpus)
    
    -- CHECK EACH NODE FOR VIABILITY
    local viable   = {}
    local rejected = {}

    -- CHECK ALL OF THE HOST QUOTAS AND JOB_DESC.EXC_NODE AND NODES THAT FAIL
    for hostname, quota in pairs(gpu_node_quotas) do
        local errors = {}

        -- Error check
        local cpu_per_gpu = num_cpus / num_gpus
        if cpu_per_gpu > quota.cpu_per_gpu then
            table.insert(errors, string.format(
                "cpu/gpu %.1f > quota %d",
                cpu_per_gpu, quota.cpu_per_gpu))
        end

        -- Error check
        if mem_mb == 0 then
            table.insert(errors, "no memory requested")
        else
            local mem_per_gpu = mem_mb / num_gpus
            if mem_per_gpu > quota.mem_per_gpu then
                table.insert(errors, string.format(
                    "mem/gpu %.1fGB > quota %.1fGB",
                    mem_per_gpu / 1024, quota.mem_per_gpu / 1024))
            end
        end

        if #errors == 0 then
            table.insert(viable, hostname)
        else
            table.insert(excluded, hostname)
        end
    end

    -- All nodes failed — hard reject
    if #viable == 0 then
        user.info("No nodes can satisfy your GPU resource request.")
        return slurm.ERROR
    end

    -- Some nodes failed — append them to exc_nodes
    if #excluded > 0 then

        -- Concatenate the host names to exclude from this job
        local exc_hostlist = table.concat(excluded, ",")

        -- Append to any existing exc_nodes rather than overwriting
        if job_desc.exc_nodes and job_desc.exc_nodes ~= "" then
            job_desc.exc_nodes = job_desc.exc_nodes .. "," .. exc_hostlist
        else
            job_desc.exc_nodes = exc_hostlist
        end

        slurm.log_user("job_submit: job was excluded from nodes " .. 
                       exc_hostlist .. 
                       ". Too much cpu/memory requested per gpu.")
    end

end
