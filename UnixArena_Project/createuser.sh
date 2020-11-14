#!/bin/bash
# setup-osingh-user
# create osingh user for Ansible automation
# and configuration management
# create osingh user
getentUser=$(/usr/bin/getent passwd osingh)
if [ -z "$getentUser" ]
then
  echo "User osingh does not exist.  Will Add..."
  /usr/sbin/groupadd -g 2002 osingh
  /usr/sbin/useradd -u 2002 -g 2002 -c "Ansible Automation Account" -s /bin/bash -m -d /home/osingh osingh
echo "osingh:<PUT IN YOUR OWN osingh PASSWORD>" | /usr/sbin/chpasswd
mkdir -p /home/osingh/.ssh
fi
# setup ssh authorization keys for Ansible access 
echo "setting up ssh authorization keys..."
cat << 'EOF' >> /home/osingh/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6GxTT/r27CyOEiGmr4qwg3l6Imco+1YmqKwwfFqss                                             tQDPlGPHKzE73dBZ6hEe7pocHpTvonuly134mtzCYTJaKhuI7B1XZO+fxvLbISMJPl4M6LBpPXGIL4/t                                             oZJgftKC877mb+hgtx2Gow86UItQWSfUukmW3djUNZbSY+wZOr2RUemMfAjrMCYmM1nKUW/CTyEuJXXa                                             /U5MmSnVQFB66cnxf/0bFKMwrOvijn0D73Y6SXQ2og0PDDVzPpYLq9rGP8tgKjCnnsQe/+p9Fq8BxmxH                                             cLdX4c8xAj4ioOsL+eEnzaCZO2BfchrhDS/xVvln3Ij57M3Aska99ToQ1l6DVcVkkr82t38/5Kx60kEr                                             o6Dz9PNDpQkFl55iR5leb1imxS26eYxGTz4pXDLbAFb5T2mTpP8iM93EsA1kf1xqwAxXT3C9DgUtgxvt                                             +nKZ1bNi3AYGuCZnhPEagNmNTYlBdXqb5Z6zdvf203LiaaLzhjIHUDlRtCDUwDoKEiCdwYM= root@an                                             sible
EOF
chown -R osingh:osingh /home/osingh/.ssh
chmod 700 /home/osingh/.ssh
# setup sudo access for Ansible
if [ ! -s /etc/sudoers.d/osingh ]
then
echo "User osingh sudoers does not exist.  Will Add..."
cat << 'EOF' > /etc/sudoers.d/osingh
User_Alias ANSIBLE_AUTOMATION = osingh
ANSIBLE_AUTOMATION ALL=(ALL)      NOPASSWD: ALL
EOF
chmod 400 /etc/sudoers.d/osingh
fi
# disable login for osingh except through 
# ssh keys
cat << 'EOF' >> /etc/ssh/sshd_config
Match User osingh
        PasswordAuthentication no
        AuthenticationMethods publickey
EOF
# restart sshd
systemctl restart sshd
# end of script
