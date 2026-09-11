# Bug Report for Watercraft Linux

## **Short Description**
### Give a 1-4 sentence description of the bug, for referencing it at a glance.

Ex: 

```
Annoying GUI auto-exiting bug when installing. Happens during configuring tzdata.
```

## **Stage**
### What stage of the software usage did the bug occur?

Possible choices: [`build-time`, `live-installer`, `during-installation`, `post-installation`]


---
## **Describe what happened | What commands were run**

### Explain the exact series of actions you took leading to this bug.

Write it up in numbered steps if it's not too many, otherwise just bulletpoint major steps.

***Example***

1. ran some commands (give EXACT commands ran)
2. rebooted system 
3. met with broken bootloader 

***(etc...)***

---
## **Logs**

### Provide all relevant logs, for example `during-installation` bugs:
```sh
# find your refracta logs here 
/var/log/refractainstaller_error.log

# or if installing again to get logs run with
# refractainstaller -d
```

If you are unsure where to find the logs for your specific bug, just say so and we will followup if necessary.


## **System Information**

### Did the bug occur:
- on a bare metal host installation?
- on any VM installation or instance of Watercraft?
- on your bare-metal base build system?

### If it occurred on any VM / QEMU installation or instance:

Provide the **EXACT** `qemu` command that you are entering or at minimum the shape of it with any personal filepaths omitted

### If it occurred on hardware 
#### (bare-metal Watercraft install host or base build system)

Please provide:

- hardware make and model (AMD or Intel CPU and model, same with GPU if relevant to bug report)
- UEFI or BIOS `[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS`
- Dual booting with other OSs? (other linux distros count)

## **Reproducibility**


### Whether the bug you are reporting is **FULLY** reproducible or **NOT-YET** reproducible, it still may be worth submitting.

- If it is **FULLY** reproducible, the major context you need to provide are those reproduction steps.
- If it is **NOT-YET** reproducible, you may still submit the bug if you report your available context carefully, accurately, and exhaustively.
- If you cannot determine the reproducibility of your bug, but still think you found something worth reporting.
    - Get in touch with someone who can help you nail down your context.
    - We will provide internal contact resources for this here in the future. 
