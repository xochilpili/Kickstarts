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

cat >> /etc/rc.d/init.d/livesys << EOF

# set up lightdm autologin
echo "Setting up lightdm autologin."

sed -i 's/^#autologin-user=.*/autologin-user=liveuser/' /etc/lightdm/lightdm.conf
sed -i 's/^#autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
#sed -i 's/^#show-language-selector=.*/show-language-selector=true/' /etc/lightdm/lightdm-gtk-greeter.conf

echo "Set Cinnamon as default session..."
# set Cinnamon as default session, otherwise login will fail
sed -i 's/^#user-session=.*/user-session=cinnamon/' /etc/lightdm/lightdm.conf

# Show harddisk install on the desktop
echo "Show hardisk install on the desktop..."
sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
mkdir /home/liveuser/Desktop
cp /usr/share/applications/liveinst.desktop /home/liveuser/Desktop

# and mark it as executable
chmod +x /home/liveuser/Desktop/liveinst.desktop

# this goes at the end after all other changes. 
echo "Chowning liveuser folder..."
chown -R liveuser:liveuser /home/liveuser
restorecon -R /home/liveuser

echo "Applying gsettings..."

#setting theme
cat > /usr/share/glib-2.0/schemas/cinnamon-live.gschema.override <<EOF
[org.cinnamon.desktop.interface]
gtk-theme='Dark-Line'
[org.cinnamon.theme]
name='Dark-Line'
EOF
#saving glib database
glib-compile-schemas /usr/share/glib-2.0/schemas/

echo "This works?"

EOF

%end

