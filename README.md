# Dynamic Configuration Reference

### Dynamic Configuration

This unikernels shows the most basic use of MirageManager. Only the variable 
values are stored and transmitted to the rpository. No information about 
control flow and execution state are written to the store. After a resumption
the execution restarts from the beginning, but with the stored variable values.
To react to control messages in the Xenstore, the unikernel runs the main loop from 
the Control module as a promise, racing with a functionality promise. If
one of them finshes, the unikernel will take the returned action an either terminate 
or suspend.

### Build

The build is automatic and can be invoked by running the `build_kernel.sh` script.
This will build one Xen image for DHCP unikernels and on for static IP unikernels.
Both must be uploaded to git, for MirageManager to be able to use them.