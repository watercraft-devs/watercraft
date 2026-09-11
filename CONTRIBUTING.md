# Contributing to Watercraft

## Scope

Watercraft is currently a small project, in order to ensure it progresses efficiently its scope will be voluntarily limited until it gains more traction.


### In-Scope Contributions:

- Build or Install path fixes
- Relevant provisioning scripts or updates to existing ones
- Documentation of things that are unclear
- Reproducible bug reports

### Out of Scope / Regulated Contributions:

- Do not add actual software to the base image, as of now this is strictly prohibited
    - Suggest a provisioning script or addition to an existing one if you think a certain software should be included
- Do not make `Init system`, `display server`, or `desktop environment` level changes. 
    - For now the defaults are a strict standard, users can configure these things post-install if they so choose
- Do not ship unclear scripts:
    - All shell scripts that install software are meant to be as clear as possible, minimal cleverness in favor of readability
    - Readability leads to maintainability and also ensures users have a chance to verify the software they are running
    - Installation scripts touch `sudo` and often quickly do operations that if unchecked can be dangerous, and are thus worthy of plausible suspicion 
---
## Script Conventions

See: [docs/provisioning_script.md#script-conventions](docs/provisioning_script.md#script-conventions)

---

**READ: [iso_dev_2026.md](dev/iso_dev_2026.md) for important building information**

---
## Testing

### **Nothing goes in without verifying a clean boot on a clean VM**
### For a build to be acceptable you must first:

1. Build the `ISO` from your `build-time` VM
2. Boot the built ISO in a clean `install-test-time` VM to confirm the expected desktop and launcher icons are present
3. Install it to your clean `install-test-time` VM disk
4. Boot into the installed system **FULLY** 
    - The only account should be the one you made during install (renamed over from liveuser during installation) with no `build-time` artifacts remaining
5. Login with the user and password you set during install
6. Ensure everything works as intended, and that any implemented updates such as provisioning scripts are as expected

Check out [docs/BUILD.md](docs/BUILD.md) for the latest in-depth build instructions and tips

---
## Bug Reports

See: [docs/bug_report.md](docs/bug_report.md) for full details.

**NOTE: Any bug found that is relevant also to Devuan, Refracta, or any other base software that Watercraft uses needs to be cross reported to the respective repository of said base software, not only reported here**

Include in your bug report:

- **Stage**: When was the bug found? `build-time` `liveuser-boot` `during-install` `post-install-pre-login` `post-install-post-login`
- **Command**: The exact command that failed, or the user perceived error if exact command unknown
- **Logs**: Relevant log output, exact lines not a summary
- **Reproducibility**:
    - Whether the bug you are reporting is **FULLY** reproducible or **NOT-YET** reproducible, it still may be worth submitting.
    - If it is **FULLY** reproducible, the major context you need to provide are those reproduction steps.
    - If it is **NOT-YET** reproducible, you may still submit the bug if you report your available context carefully, accurately, and exhaustively.
    - If you cannot determine the reproducibility of your bug, but still think you found something worth reporting.
        - Get in touch with someone who can help you nail down your context.
        - We will provide internal contact resources for this here in the future.

In ALL cases, reproducibility implies that this bug is reproducible within the context of the current state of Watercraft

**Modifying Watercraft heavily and yielding a bug is NOT REPRODUCIBILITY and is not within the scope of Watercraft**

**DO NOT SUBMIT BUG REPORTS THAT ARE IRRELEVANT TO THE STATE OF OR DIRECTION OF THE PROJECT**

