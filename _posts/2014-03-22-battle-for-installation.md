---
layout: post
tags: linux ubuntu asus grub
id: c9df9234-fcdc-4963-9e78-94f58491da34

---
I recently came into possession of an ASUS 1225b netbook with Windows 7 installed. It's a little beat up (the hinge is a goner) but a lot better than the nothing I had before. So, first things first, install Ubuntu.

- Download the torrent
- Grab a usb stick
- Use [UUI](http://www.pendrivelinux.com/universal-usb-installer-easy-as-1-2-3/) to make it live
- Change boot order
- Boot and install

Easy, right? Not so fast. I reboot and am presented with those horrid spinning balls of color that is the Windows boot screen. What happened, why have the gods of grub forsaken me?

## Booting Fedora
My First thought is, of course, install grub manually. So I plug the usb back in and choose to run live. At this point I run into my fist major hiccup, the mouse and keyboard don't work on 13.10 live. Well there are other live distributions out there.

A quick download and install later and I'm booting to Fedora 20 live ... only to have it hang. In vain I Google hoping to feed on the mistakes of those who have come before me, but none came to my rescue. As a last ditch effort, I decide to make a new usb with `dd` instead of UUI. The system barely fit on my usb so just maybe that created the issue. Only problem is that I do not have a linux installation. Our old friend Google spit out [dd for Windows](http://www.chrysocome.net/dd), copy that to `system32` and we're in business.

~~~ bash
dd if=c:\Users\***\Downloads\fedora.iso of=\\.\f:
~~~

Plug in the new usb stick and it boots!

## Reinstalling grub
Since we have a (presumably) working system installed, the easiest way to install grub is to `chroot` into Ubuntu and install from there.

``` sh
su -
mount /dev/sda6 /mnt
for i in /dev /dev/pts /proc /sys /run; do
    mount --bind $i /mnt$i
done

# For internet access
mv /mnt/etc/resolv.conf /mnt/etc/resolv.conf.old
cp /etc/resolv.conf /mnt/etc/resolv.conf

chroot /mnt
```

Now to purge and reinstall grub.

~~~ bash
apt-get update
apt-get purge grub-common
apt-get install grub-pc
grub-install /dev/sda
update-grub
~~~

Everything looks successful. I cross my finders, reboot ... and I'm back to the Windows login screen. No no no, Where did I go wrong!

## The fix
I do some more Googling. I bump my head against the desk a few times. I comb through the BIOS looking for anything that would bypass grub. I ... wait, there it is! I have two boot options:

- primary harddisk
- UEFI: my usb

I was booting the install medium as UEFI. I'm not using UEFI, I do not have a UEFI partition. This must be the problem. Under the boot priority selection there's harddisk priority selection. Change that to my usb, save & reboot, repeat grub installation, reboot, and voilà!

The moral of the story? Check your boot options *before* you install.

## Epilogue
One last thing, we have to move the resolve file back. I forgot and it took me way to long to realize why I could't connect on some networks.

~~~ bash
sudo rm /etc/resolv.conf
sudo mv /etc/resolv.conf.old /etc/resolv.conf
~~~
