# Assignment: Media Files Backup and Restore Service - PackUp

Inspired by rugged backpacks, it quickly became the trusted guardian of digital memories

## Activity F1

**Prerequisites:** A Vagrant VM with local folder syncing capability set up.

**Objective:** Create a media files backup service.

**Task:** Develop a shell script named `bkmedia.sh` to manage backups of media files from multiple sources.

**Details:** A file named `locations.cfg` will store server locations in the format: `[user]@[server host]:[path]`.

**Example:**

    user1@192.168.1.1:/home/user1/images/
    bkup@somehost.example.com:/var/log/
    vagrant@localhost:/tmp/

## Script functionalities

1. Running without arguments: Display configured locations, preceded by line numbers.
2. Backup: - Run with `-B`: Initiates backups for all locations. - Use `-L n` with `-B`: Initiates backup only for the specific location by line number `n`.
3. Restore: - Run with `-R n`: Indicates which backup (from the most recent) to restore. - Use `-L n` with `-R`: Designates which location to restore from. - Note on SSH keys: Ensure the executing user's public SSH key is set up on servers you intend to back up.

## Activity F2 (Optional)

**Objective:** Enhance the backup service in terms of performance and cost-efficiency.

**Task:** Propose design alterations to the existing setup. Address performance bottlenecks and devise strategies to reduce data storage costs.

**Details:** - Consider backup speed optimizations. - Explore data compression, deduplication, or other data optimization techniques. - Outline the specific changes to be integrated into your current solution based on your new design.

## Curveball: Alien Formats

One of the servers in locations.cfg has started producing media files in a never-before-seen alien format called .xyzar. This new format is 5x the size of regular media files but contains essential intergalactic data that cannot be missed!

**Task:** Modify bkmedia.sh to:

**Detect:** Identify .xyzar files during the backup process.

**Optimize:** Compress .xyzar files before backup to manage their larger size.

**Document:** For each .xyzar file backed up, generate a brief report detailing its size before and after compression, timestamp, and server source. Store these distinct reports in a folder named alien_logs daily.

**Remember:** Alien data is crucial! Handle with care, and may the force be with you! 🌌👾

## Curveball: Time Warp Anomalies

Mysterious time-warp anomalies have been detected. These anomalies cause media files to randomly “time travel,” either forward or backward, by a maximum of 3 days from their original timestamp.

**Task:** Modify bkmedia.sh to:

**Detect:** During the backup process, identify any file with a timestamp seemingly changed due to the time warp (i.e., any file ahead or behind its expected timestamp by up to 3 days).

**Flag & Log:** Mark these files with a .timewarp extension so they can easily be identified. For each time-warped file, generate a log entry detailing its original timestamp, the new timestamp, and the difference in hours.
Restore Adjustment: When restoring a backup, provide an option `-T` that provides the ability to adjust time-warped files to their original timestamp automatically.

**Remember:** Time is of the essence! Ensure no file gets lost!

## Deadline: 2w

**Submission:** Share your scripts and design documents through Teams. Documents and Code should come via GitHub links.

I will have office hours once per week for open questions. I can answer other questions via Teams.

This is not intended to work perfectly as described, adapt!

Let's innovate and create an efficient backup service! 🚀

## Helpful Links

[Missing CS semester](https://missing.csail.mit.edu/2020/)

[Vagrant Docs](https://developer.hashicorp.com/vagrant/tutorials/getting-started/getting-started-index)
