# Oracle Cloud NixOS Setup
As of writing this document (December 2025), Oracle Cloud does not provide ready-to-use NixOS images.
Uploading the NixOS setup as Custom Images does also not work, as installation needs manual intervention.

However, it is possible to set up NixOS on Oracle Cloud by manually booting the NixOS installation ISO using a
cloud console connection.

## Installing NixOS
Follow the steps below to install NixOS on an Oracle Cloud instance:

### Step 1: Create an Instance
1. Go to [Create compute instance.](https://cloud.oracle.com/compute/instances/create)
2. Configure the instance according to your needs (shape, networking, etc.).
3. Under “Image and shape,” choose the image Ubuntu > ``Canonical Ubuntu 24.04 Minimal`` or ``Canonical Ubuntu 24.04 Minimal aarch64`` (or a newer version if available).
4. Complete the instance creation process.

### Step 2: Prepare netboot.xyz
1. Connect to the instance using SSH.
2. Elevate to root:
   ```bash
   sudo -i
   ```
3. Download the netboot.xyz image:
   ```bash
   # for arm64 architecture
   wget https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi && \
     sudo install \
       --owner=root \
       --group=root \
       --mode=664 \
       netboot.xyz-arm64.efi \
       /boot/efi/netboot.efi
   
   # for amd64 architecture
   wget https://boot.netboot.xyz/ipxe/netboot.xyz.efi && \
     sudo install \
       --owner=root \
       --group=root \
       --mode=664 \
       netboot.xyz.efi \
       /boot/efi/netboot.efi
   ```

### Step 3: Boot into netboot.xyz
1. Create a new 'Cloud Shell connection' for the instance from the Oracle Cloud console.
   Wait until the connection is ready:
   ```txt
   Instance Console Connection reached state: ACTIVE
   ```
2. Reboot the instance from the previous SSH session:
   ```bash
   sudo reboot
   ```
3. In the Cloud Shell connection, press `ESC` repeatedly until the boot menu appears.
4. From the boot screen, go to Boot Manager > EFI Internal Shell.
5. In the EFI shell, run the following command to boot netboot.xyz:
   ```txt
   fs0:netboot.efi
   ```

### Step 4: Install NixOS
1. In the netboot.xyz menu, select `Distributions > Linux Network Installs > NixOS`.
2. Configure SSH access. You can use GitHub for this: ``mkdir -p ~/.ssh && curl https://github.com/USERNAME.keys >> ~/.ssh/authorized_keys`` (replace `USERNAME` with your GitHub username).
3. Follow the [NixOS installation guide](https://nixos.org/manual/nixos/stable/#sec-installation) to install NixOS.
4. After installation, reboot the instance.
5. Profit!

## References
- [Install NixOS on a Free Oracle Cloud VM](https://mtlynch.io/notes/nix-oracle-cloud/) by Michael Lynch
- [NixOS on Free Oracle Cloud Arm A1](https://discourse.nixos.org/t/nixos-on-free-oracle-cloud-arm-a1/17474) by Thomas131
