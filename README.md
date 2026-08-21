A Bash security tool which helps you audit your directories and your files by detecting permission change, owner change, and content change using hash checksum.

## Lab Setup
Before running the script, you should create a safe target directory and put your dummy config files there:

```bash
mkdir -p /tmp/lab_sandbox/etc/ssh
mkdir -p /tmp/lab_sandbox/etc/pam.d

# Generate dummy config files:
echo "Port 22" > /tmp/lab_sandbox/etc/ssh/sshd_config
echo "auth required pam_unix.so" > /tmp/lab_sandbox/etc/pam.d/common-auth
chmod 600 /tmp/lab_sandbox/etc/ssh/sshd_config

##Note: By default, inspect.sh targets /tmp/lab_sandbox/etc. You can change TARGET_DIR inside inspect.sh to monitor any path on your system.

## by ./inspect.sh --build you can build your baseline
## after building the baseline now use ./inspect.sh --check to check for drifts

```
