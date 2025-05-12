# quel-firmwares

## Getting started

To download firmware images, please run the following command in your terminal:

```sh
wget -O /tmp/d.sh https://quel-inc.github.io/quel-firmwares/quel_firmware_downloader.sh && chmod +x /tmp/d.sh && /tmp/d.sh
```

If you have previously downloaded firmware images, this command will replace the old images with the new ones.

The firmwares will be stored in `$XDG_DATA_HOME/quelware/firmwares/`.
On Linux system, this typically resolves to `~/.local/share/quelware/firmwares/`.

To remove the downloaded files, please run the command above with `-r` option, or manually delete the directory.

### For v0.8.x users

To download firmwares for `v0.8.x`, please run:

```sh
wget -O /tmp/d.sh https://quel-inc.github.io/quel-firmwares/quel_firmware_downloader.sh && chmod +x /tmp/d.sh && /tmp/d.sh -p for_0.8
```


## For developers

This repository uses [Git LHS](https://git-lfs.com/) to deal with large binary files.
Make sure to install `git lfs` on your system before working with this repository.
For installation instructions, please refer to the official [guide](https://github.com/git-lfs/git-lfs?utm_source=gitlfs_site&utm_medium=installation_link&utm_campaign=gitlfs#installing).
