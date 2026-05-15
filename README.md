# slurm-job-submit

## How to install Slurm on your Linux desktop

Install with apt

`apt install slurmctld`

Edit `/etc/slurm/slurm.conf`

```
   ClusterName=localtest
   SlurmctldHost=localhost
   MpiDefault=none
   ProctrackType=proctrack/linuxproc
   ReturnToService=2
   SlurmctldPidFile=/var/run/slurmctld.pid
   SlurmdPidFile=/var/run/slurmd.pid
   SlurmdSpoolDir=/var/spool/slurmd
   StateSaveLocation=/var/spool/slurmctld
   SwitchType=switch/none
   TaskPlugin=task/none
   JobSubmitPlugins=lua
   SlurmUser=slurm

   # Node config — adjust CPUs/memory to match your laptop
   NodeName=localhost CPUs=4 RealMemory=8000 State=UNKNOWN
   PartitionName=debug Nodes=ALL Default=YES MaxTime=INFINITE State=UP
```

`mkdir /var/spool/slurmctld`

`sudo chown slurm:slurm /var/spool/slurmctld`

`sudo chmod 755 /var/spool/slurmctld`


`mkdir /var/spool/slurmd`

`sudo chown slurm:slurm /var/spool/slurmd`

`sudo chmod 755 /var/spool/slurmd`



Add `/etc/slurm/job_submit.lua`

`systemctl start slurmctld`

`systemctl status slurmctld.service -n 50`

`scontrol reconfigure`
