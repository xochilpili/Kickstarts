# fedora-livecd-cinnamon.ks
#
# Description:
# - Fedora Live Spin with the Cinnamon Desktop Environment
#
# Maintainer(s):
# - Dan Book <grinnz@grinnz.com>
# Editor(s): 
# Corey84; xochilpili 
#
services --enabled=NetworkManager --disabled=sshd
network --device=enp0s3 --onboot=yes --bootproto=dhcp

repo --name=PAranoids --baseurl=http://fedora.paranoids.us/rpmbuild/ 

%include /usr/share/spin-kickstarts/fedora-live-base.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks
%include /usr/share/spin-kickstarts/fedora-cinnamon-packages.xOCh.ks

# im goint to take this lines to fedora-cinnamon-packages.xOCh.ks
%packages
wget
lynx
gdm
backgrounds.noarch
cinnamon-spin-themes.noarch
%end #<- thrown an error missing;
# DVD payload
part / --size=6144

# cinnamon configuration
%post --log=/root/kickstart-post.log #<-- adding
echo "Starting Kickstart shit..."
# create /etc/sysconfig/desktop (needed for installation)
cat > /etc/sysconfig/desktop <<EOF
PREFERRED=/usr/bin/cinnamon-session
DISPLAYMANAGER=/usr/sbin/gdm
EOF
 
# exclude GNOME-specific menu items
desktop-file-edit --set-key=NoDisplay --set-value=true /usr/share/applications/fedora-release-notes.webapp.desktop
desktop-file-edit --set-key=NoDisplay --set-value=true /usr/share/applications/yelp.desktop
 
cat >> /etc/rc.d/init.d/livesys << EOF

cat >/etc/yum.repos.d/PAranoids.repo <<EOF
[PAranoids]
name=PAranoids $releasever - $basearch
baseurl=http://fedora.paranoids.us/rpmbuild/
enabled=1
EOF


#dnf install --installroot=/mnt/sysimage gdm wget lynx -y;
#dnf install -y --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
#dnf update --refresh -y

# set up gdm autologin
#-> not working sed -i 's/^#autologin-user=.*/autologin-user=liveuser/' /etc/gdm/gdm.conf
#-> not working sed -i 's/^#autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/gdm/gdm.conf

echo "Aqui esta el error?"
gsettings set org.gnome.desktop.session session-name cinnamon
gsettings set org.cinnamon.desktop.interface gtk-theme Dark-Line
gsettings set org.cinnamon.theme name Dark-Line


cat >/etc/gdm/custom.conf <<EOF
[daemon]
#activar el registro automatico
AutomaticLogin=liveuser
AutomaticLoginEnable=true
# set Cinnamon as default session, otherwise login will fail
DefaultSession=cinnamon.desktop
EOF

systemctl enable gdm

 
# set Cinnamon as default session, otherwise login will fail
#-> not working sed -i 's/^#user-session=.*/user-session=cinnamon/' /etc/gdm/gdm.conf
 
# Show harddisk install on the desktop
sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
mkdir /home/liveuser/Desktop
cp /usr/share/applications/liveinst.desktop /home/liveuser/Desktop
 
# and mark it as executable
chmod +x /home/liveuser/Desktop/liveinst.desktop
 
# this goes at the end after all other changes.
chown -R liveuser:liveuser /home/liveuser
#<> i messed up selinux :> restorecon -R /home/liveuser


%end

