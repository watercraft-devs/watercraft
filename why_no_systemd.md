# Why is Watercraft opposed to systemd?

*Modern systemd is much more than an init system, and that is precisely the issue.*

---
-  An init system is basically supposed to be a way you can start and stop system processes.
-  By leaving that scope, systemd has creeped into an entirely individual category of systems.
-  What once started as truly just an init system, now "handles" (or attempts to handle):
    - login 
    - network 
    - timesync 
    - journaling 
    - etc...

The consequences of scope creep in systemd  can be boiled down to these 3 pillars which explain our fundamental opposition:

## 1. **Abandons UNIX philosophy and reduces maintainability of operating systems**
Historically, individual processes had their own logs, their own code, their own release cycle, etc... but nowadays they are wrapped into systemd creating a jungle of obstacles for debugging, extending, and improving the software.

Unix was about **"Do one thing and do it well"**, that's what made it the ideal model for a coherent maintainable operating system in which administration and management of it is a pleasant experience.

It also meant that people building on top of UNIX knew exactly how much shifting sand there was under their feet, and the amount was very little purposefully.

Every process that got absorbed by systemd used to be an isolated, coherent, easy to reason about application of its own.


**Users** being able to learn how to **freely modify and upgrade their own systems and software**  was exactly the intention of Linux originally.

By exponentiating the complexity of knowledge required to even reason about the software, systemd has willingly neutered this fundamental goal.

Being able to learn how to freely modify your own system and software is still largely why most people continue using Linux at all, systemd's design decisions inherently seem to block this market demand from being met.

systemd made architectural decisions that create **frequent dependency knots**, in which a **user can functionally brick their system** by accidentally deleting something that **might look entirely unnecessary for their system to operate**.

This cluster of package dependencies **disincentivizes users slimming down their own system packages**, which **destroys another key concept that draws people to Linux in the first place**.

---
## 2. **Has the tendency to break working systems, which highlights its oversold convenience pitch**

The pitch with systemd is basically: ***"It's convenient because sysadmins don't have to stretch their fingertips to manipulate all the processes now".***

The reality is that **defaults for software behaviors can change unexpectedly**, which snowballs into **breaking user configurations unexpectedly**.

Users who operate within perfectly reasonable constraints get their **systems ruined by one update**, and that is unacceptable.

The clearest example is `systemd 230`'s `KillUserProcesses` getting **switched on by default by just one inconspicuous update**.

**Processes that were left running were killed**, for a desktop that's curse-word inducing inconvenience but on an enterprise grade server holding valuable data, it could be armageddon. 

Notice how **if systemd didn't automatically touch all the user's processes, this would be an impossibility all together**.

**The init system should not have this kind of overreaching hand, it should be like a butler, not a dictator**.

---
## 3. **Coupling independent components results in "Trickle-Down Vulnerabilities" inherited by all end-users**
systemd's dependency knots (discussed in section 1.) implicitly **prevent configuration away from their assumed standard of softwares** that come bundled with it.

If just one of these softwares contains a vulnerability, systemd users who have no use for that software are **still vulnerable by default**.

The clearest recent example of this is [CVE-2026-3888](https://cybersecurity88.com/news/ubuntu-cve-2026-3888-timing-flaw-in-systemd-cleanup-enables-root-privilege-escalation/) which was a **`snapd` root privilege escalation exploit**.
It happens because of a `race-condition` between `snap-confine` and `systemd-tmpfiles`.

The race condition is only possible because of two bad designs on both sides:

systemd:
 
- Managing temp files is not an implicit behavior of an init system, when done it opens the potential to **clobber the state of parallel processes** that the init system may not be directed to touch.
- Security sensitive application state should always avoid being clobbered by a sub system, however at a certain point the onus becomes on the sub system itself not to make it a possibility.
- **Alternative init systems do not touch your temp files at all, removing this class of interaction  entirely**.

snapd: 

Making a folder that holds trusted executables:
 
1. based just on its name/location 
2. making it defined as temp under systemd setups 
3. not properly confining something called "snap-confine" ...

In practice this means that **developers have to see systemd adversarially by default**, because if they don't it may spawn race conditions silently.

This vulnerability was only possible with a **combination of processes**, proving how **coupling processes that are not essentially cohesive** is asking for trouble.

100% of Devuan users (and users of all other non-systemd distros) avoided this CVE, and **there was no mitigation other than not using systemd for init**.

Historically `PID 1`, the PID that init systems use, was kept simple purposefully because it has no parent to restart it.

**More code, libraries, and untrusted input** shoved into `PID 1` obviously creates a **worse security posture** than having it only consist of basic init scripts.

**`PID 1` should stay only the size/scope necessary  to handle its basic functionality of being an init system.**

---
**It should be noted that this is not an extensive list of the reasons Watercraft is opposed to systemd, but there is plenty here that summarizes the most crucial and technologically focused reasons for opposition.**
