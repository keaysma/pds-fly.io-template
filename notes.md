# Notes I learned while studying PDS stuff
## installer.sh
- This is going to ultimately create an "ecosystem" of 3 services managed by a docker compose, and that docker compose can be turned on/off using systemd
- Docker system containers 3 parts:
    - Watchtower: This is a container that makes sure other containers are up-to-date. Outside of running this from your own computer, this program isn't portable or useful
    - pds: The whole reason we are here, this is the PDS software. It needs access to a persistent volume where it will read/write sqlite files
    - caddy: This is basically an alternative to something like nginx. It manages HTTPS upgrades. Like Watchtower, this doesn't really make sense outside of a dev environment, not useful for the project
- Both the docker compose is downloaded from github, systemd config is directly imbedded in the file
- This script does a bunch of PITA checks to make sure you don't setup an unusable system. Usually that's good, but I found this annoying (let me break this thing dang it!)
- From here we can reverse engineer how to create the secret values for pds.env

## pds.env
- `PDS_JWT_SECRET`: Used as a seed for creating JSON Web Tokens for account authorization
```bash
# This is what's in installer.sh
PDS_JWT_SECRET=$(eval "${GENERATE_SECURE_SECRET_CMD}")

# That is just going to run this
GENERATE_SECURE_SECRET_CMD="openssl rand --hex 16"
# So make sure you have openssl installed
# Ultimately, this is what you'd want to run
openssl rand --hex 16
```

- `PDS_ADMIN_PASSWORD`: Used when doing administrative things on your PDS (creating/deleting accounts)
```bash
# From installer.sh
PDS_ADMIN_PASSWORD=$(eval "${GENERATE_SECURE_SECRET_CMD}")

# Same thing as PDS_JWT_SECRET
openssl rand --hex 16
```

- `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX`: TBH, not sure. I think this is used for creating new DIDs?
```bash
# From installer.sh
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=$(eval "${GENERATE_K256_PRIVATE_KEY_CMD}")


# The underlying command is similar but more complex as compared to the last two
openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32

# This does a couple things, chained together:
# 1. Generate a private signing key
# 2. Skip the first 8 bytes of the output
# 3. Grab the first 32 bytes from step 2
# 4. Convert bytes to plaintext hexadecimal
```

## pdsadmin
- This is a bash file, that downloads other bash files from github, and runs them
- The downloaded bash files ultimately just run cURL commands
- This also has some very PITA checks to make sure the pds.env file is in a root directory folder, and ensures that you are root using a linux-only (ubuntu-only?) system variable
- I made pdsadmin-command.sh which is just a reverse-engineer of some of the necessary tools, distilled down into what they do under the hood, ultimately