# **Provisioning Script Information**

**`Provisioning Scripts` are `payloads` that install software to a `Watercraft` system or in some cases apply `configurations` to the system**

Therefore **IN ALL CASES** they need to be clearly explained when submitted for proposition

Maintainers are currently working on documenting all the existing `provisioning scripts` the way proper submissions would be.



## **Script Conventions**

#### *Due to change with governance*

**For all HIGH-LEVEL provisioning and other propositionally shipped scripts**

- EVERY high-level provisioning script MUST prompt the user about every software that is being installed
    - Whether the prompt is one per software or one per group of software can vary, choose practically
    - If the software is non-verifiable, this must be clearly stated
    - If the install includes tons of dependencies, list them categorically or exhaustively in the prompt
- Right now, every script that installs packages is pure `bash`/`sh`.
    - Keep it that way until further notice.
    - These scripts are `#!/bin/bash` and meant to be `executed` NOT `sourced` (in case you're using zsh or other)
    - Keep anything intended to be `sourced` or shipped as a shell rc file **POSIX** `sh` so it works under `bash`, `zsh`, `dash`, etc...
- For compatibility across different shells on individual scripts (nice to have)
    - quote EVERY expansion
    - avoid indexing ideally or handle it based on shell environment if you must index
        - (bash arrays are `0-indexed` and zsh is `1-indexed`)
    - don't use indirect expansion via `${!var}`

**For updates to CORE provisioning scripts and propositional additional core scripts**

- Scripts that touch important files MUST be `Idempotent`
    - don't overwrite important stuff by accident (or on purpose...)
    - don't clobber scripts that touch important services
    - every script should be runnable `n` amount of times on the same build system with 0 unwanted side-effects


If you are unsure, check example real provisioning scripts such as:

- `provisions.sh` for a core-provisioning script example
    - generally only edits, updates, upgrades should be suggested to core-provisioning scripts
    - new core-provisioning scripts will be under much higher scrutiny than high-level ones due to: 
        - security implications
        - lack of user-prompt requirement per software
        - inherent bias risk
- `amusements.sh` for a high-level provisioning script example (provisioning is just a concept, scripts don't **HAVE** to include the word `provision` in the name...)
    - the kind of provisioning script we would expect as a contribution
        - (in terms of SHAPE not necessarily package contents)
    - updates to high-level provisioning scripts are also just as expected
        - (for example if you want to add some multi-media entertainment software to a script, just propose adding it to `amusements.sh`)
    - if your script can be folded in reasonably to an existing one we will ask you to do so if you haven't already
        - (updates are better than new entire scripts generally)

---

# **How to submit:**

- If you are **updating/changing** an **existing** `high-level` provisioning script:
    - open a **direct pull request**
    - still include the **required categories** listed below with your PR accordingly (included as an .md file w/ the submission)
- If you are **adding** a **new** `high-level` provisioning script:
    - open an **issue first** with the **required categories** listed below provided
    - this is to prevent you from writing up a **new** script of stuff that can be included comfortably in an **existing** one
        - (we want to prevent having tons of disparate scripts especially of internally aligning software and/or config classifications)    
    - after the maintainers confirm the shape of the update via the issue, you can open a PR implementing it
- If you are **updating/changing** ANY `core` provisioning script (or in the rarest circumstances proposing a brand new one):
    - open an **issue first** no matter what
    - `core` scripts touch important OS configurations and data on **EVERY WATERCRAFT INSTALL** and will be reviewed with the utmost scrutiny
    - if your issue is approved, you can implement and pull request
- In all circumstances only touch **one script file** per pull request and issue so that the scope of the change is **easy to read and reason about**

--- 
# **Provide the following categories with your submission:**

## **Dependency on systemd**

Does the software that this script installs have any known issues with dependency on systemd or anything similar?
Classify your submitted software in one of these 3 tiers:

### systemd dependency tiers

1. Totally independent and working flawlessly
2. Somewhere in the middle (re-consider a confident submission)
    - This tier starts needing considerable developer input above face-level considerations for inclusion
    - Escalation might be required depending on circumstances
3. Not working without systemd
    - This tier will require major developer input for inclusion (escalation 100% required)
    - would be pragmatic to be submitted if the script's packages are authentically life-or-death for the distribution 
        - (unlikely but not completely dismissed)

If all the submitted software doesn't fall under one category, label each software individually or in groups
If you're not sure: if it's running easily on Devuan then it likely is a `1` or a `2`
In all cases, briefly explain how extensively you have tested the software to function properly on Devuan, one explanation per whole submission is fine

## **Software Installation Specification**

For every software that the script installs:

- What is it? (name,version if relevant, etc...)
- Where does it originate? (The specific package or source origin)
- How is it installed? 
    - Devuan or Debian repo (`sudo apt install ...`)
    - Third party repo (MUST BE SIGNED AND VERIFIABLE)
    - Direct downloads (via `wget`, `curl`, etc...)
        - Packages like (`.deb`, `.AppImage`, `.tar.gz`, etc...)
        - Runs some kind of install command other than `apt`:
            - (`dpkg`, `tar -xzf`, `chmod +x`, etc...)
    - Flatpak via `flatpak install ...`
        - Not preferred over other installation methods generally, however occasionally useful for sandbox behavior
        - `snap` packages don't exist here (woohoo!) 
        - this is the avenue for noob-installs in some sense but is still only preferred when the sandbox behavior is needed
    - Something not listed here
        - if something popular was missed we will add it above
        - otherwise provide as much detail as you can assuming you still think your script is worth inclusion

**Where available as an option and makes sense BUILD FROM VERIFIED REVIEWED SOURCE CODE or at least give the user that option !!!**

## **Software Verification Specification**

- Can the software that you are installing via the provisioning script be cryptographically verified?

    - If so, you MUST provide the verification programmatically in the script

    - If not, you need to give a during-installation-prompt warning that the software is non-verifiable

    - This warning goes in the prompt that asks the user if they would like to install the current software

- Non-verifiable software is only allowed in provisioning scripts where the user is prompted for ok-to-install per software   
    - (otherwise they could slip in without a warning, unacceptable)


