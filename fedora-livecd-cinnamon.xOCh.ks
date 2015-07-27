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

%include /usr/share/spin-kickstarts/fedora-live-base.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks
%include /usr/share/spin-kickstarts/fedora-cinnamon-packages.xOCh.ks

# im goint to take this lines to fedora-cinnamon-packages.xOCh.ks
#%packages
#wget
#lynx
#gdm

# DVD payload
part / --size=6144

network --device=enp0s3 --onboot=yes --bootproto=dhcp

# cinnamon configuration
%post #<-- adding
# create /etc/sysconfig/desktop (needed for installation)
cat > /etc/sysconfig/desktop <<EOF
PREFERRED=/usr/bin/cinnamon-session
DISPLAYMANAGER=/usr/sbin/gdm
EOF
 
# exclude GNOME-specific menu items
desktop-file-edit --set-key=NoDisplay --set-value=true /usr/share/applications/fedora-release-notes.webapp.desktop
desktop-file-edit --set-key=NoDisplay --set-value=true /usr/share/applications/yelp.desktop
 
cat >> /etc/rc.d/init.d/livesys << EOF

%end #<- adding...

%post --nochroot

dnf install --installroot=/mnt/sysimage gdm wget lynx -y;
#dnf install -y --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
#dnf update --refresh -y


#my own config
# cinnamon themes :D
#hash wget 2>/dev/null || { echo >&2 "No se encontro wget :("; exit 1;} #detecting wget; a ver si no se detiene todo...
mkdir /tmp/theme/
cd /tmp/theme/
curl http://cinnamon-spices.linuxmint.com/uploads/themes/WHVC-1OMQ-6474.zip -o "Dark-Line.zip"
chown liveuser:liveuser Dark-Line.zip
chmod +r Dark-Line.zip
unzip Dark-Line.zip
#cp -r /usr/share/cinnamon/theme/ /home/liveuser/.theme/
cp -r /tmp/theme/Dark-Line /usr/share/themes/
gsettings set org.cinnamon.desktop.interface gtk-theme Dark-Line
gsettings set org.cinnamon.theme name Dark-Line
#rm -rf /tmp/theme
#end testing
 
# set up gdm autologin
sed -i 's/^#autologin-user=.*/autologin-user=liveuser/' /etc/gdm/gdm.conf
sed -i 's/^#autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/gdm/gdm.conf
systemctl enable gdm

 
# set Cinnamon as default session, otherwise login will fail
sed -i 's/^#user-session=.*/user-session=cinnamon/' /etc/gdm/gdm.conf
 
# Show harddisk install on the desktop
sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
mkdir /home/liveuser/Desktop
cp /usr/share/applications/liveinst.desktop /home/liveuser/Desktop
 
# and mark it as executable
chmod +x /home/liveuser/Desktop/liveinst.desktop
 
# this goes at the end after all other changes.
chown -R liveuser:liveuser /home/liveuser
restorecon -R /home/liveuser
 
EOF
 
%end

