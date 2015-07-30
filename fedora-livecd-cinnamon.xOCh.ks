# fedora-livecd-cinnamon.ks
#
# Description:
# - Fedora Live Spin with the Cinnamon Desktop Environment
#
# Maintainer(s):
# - Dan Book <grinnz@grinnz.com>

%include /usr/share/spin-kickstarts/fedora-live-base.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks
%include /usr/share/spin-kickstarts/fedora-cinnamon-packages.xOCh.ks

#PAranoids repo
repo --name=PAranoids --baseurl=http://fedora.paranoids.us/rpmbuild/ 

# DVD payload
part / --size=6144

%post
set -x -v 
exec 1>/root/ks-post.cinnamon.log 2>&1

# repo PARanoids
echo "Starting %post"
echo "Creating paranoids.us repo"
cat >/etc/yum.repos.d/PAranoids.repo <<EOF
[PAranoids]
name=PAranoids $releasever - $basearch
baseurl=http://fedora.paranoids.us/rpmbuild/
enabled=1
EOF

# cinnamon configuration

# create /etc/sysconfig/desktop (needed for installation)
echo "Cinnamon configuration..."
cat > /etc/sysconfig/desktop <<EOF
PREFERRED=/usr/bin/cinnamon-session
DISPLAYMANAGER=/usr/sbin/lightdm
EOF

echo "Excluding menu items of gnome."
# exclude GNOME-specific menu items
desktop-file-edit --set-key=NoDisplay --set-value=true /usr/share/applications/fedora-release-notes.webapp.desktop
desktop-file-edit --set-key=NoDisplay --set-value=true /usr/share/applications/yelp.desktop

echo "Changed the position of trying to change the theme"
cat > /usr/share/glib-2.0/schemas/cinnamon-live.gschema.override <<FOE
[org.cinnamon.desktop.interface]
gtk-theme='Dark-Line'
[org.cinnamon.theme]
name='Dark-Line'
[org.cinnamon.desktop.background]
picture-uri='file:///usr/share/backgrounds/images/black_pirate_flag.jpg'
FOE

echo "Also im gonna make a script and try to use gsettings as user..."
/bin/echo "/home/liveuser/setTheme.sh" >> /etc/rc.d/rc.local
cat > /etc/setTheme.sh << EOF
#!/bin/bash
echo "Nasty way..."
gsettings set org.cinnamon.desktop.interface gtk-theme Dark-Line
gsettings set org.cinnamon.theme name Dark-Line
echo "Executed script">/home/liveuser/debug
EOF

/bin/chmod 555 /etc/setTheme.sh

cat >> /etc/rc.d/init.d/livesys << EOF

# set up lightdm autologin

sed -i 's/^#autologin-user=.*/autologin-user=liveuser/' /etc/lightdm/lightdm.conf
sed -i 's/^#autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
#sed -i 's/^#show-language-selector=.*/show-language-selector=true/' /etc/lightdm/lightdm-gtk-greeter.conf

# set Cinnamon as default session, otherwise login will fail
sed -i 's/^#user-session=.*/user-session=cinnamon/' /etc/lightdm/lightdm.conf

# Show harddisk install on the desktop
sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
mkdir /home/liveuser/Desktop
cp /usr/share/applications/liveinst.desktop /home/liveuser/Desktop

# and mark it as executable
chmod +x /home/liveuser/Desktop/liveinst.desktop

# this goes at the end after all other changes. 
chown -R liveuser:liveuser /home/liveuser
restorecon -R /home/liveuser

EOF # end of /etc/rc.local/init.d/livesys

echo "This works?"

%end

