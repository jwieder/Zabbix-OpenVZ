# Description
OpenVZ node monitoring through Zabbix.

OpenVZ containers monitoring through Zabbix. Allows for monitoring applications within containers without the need to install a Zabbix agent on container.

Template "Template OpenVZ Node" finds all containers, creates new hosts and apply template "Template OpenVZ CT" on them.

# Dependencies
perl, sudo, zabbix-agent.

Basic Installation
============
1. copy vzdiscover.pl, ubcfault.sh and vzlist.sh to /etc/zabbix/
2. copy zabbix_agentd.d/openvz.conf to /etc/zabbix/zabbix_agentd.d/
3. copy sudoers.d/zabbix to /etc/sudoers.d/
4. chown root:root /etc/sudoers.d/zabbix ; chmod 440 /etc/sudoers.d/zabbix
5. chmod 755 /etc/zabbix/vzdiscover.pl /etc/zabbix/ubcfault.sh /etc/zabbix/vzlist.sh
6. restart zabbix-agent daemon.
7. import "zbx_templates/Template OpenVZ CT.xml" and "zbx_templates/Template OpenVZ Node.xml" into your templates.
8. apply template "Template OpenVZ Node" to OpenVZ hardware node (otherwise known as host system).

You can tune macros (like {$PROC_CT_WARN}) in template "Template OpenVZ CT", or set macros to parent host (hardware node). Macros set at the template or node level will be inherited to auto-discovered CT hosts. Unfortunately Macros cannot be customized individually for auto-discovered hosts.

Container Monitor Option 1: Install advanced container checks on node
============
Note: this approach allows Zabbix admins to extend the basic OpenVZ monitoring of CPU, RAM, UBC & disk usage provided by the Basic Install above. Open 1 does not require Zabbix agent to be installed within a container, the existence of a Zabbix user or group on the container, modifications of sudo permissions on the container or the creation of any files on the container. Everything takes place on the node. The downside of this approach is that it can be difficult to implement individualized checks for each container on the node - as presented here, every container on the node will be checked using the same shell command or script. If there is a high degree of application variability between containers on the same node, this can produce a large amount of UNAVAILABLE monitoring items when Zabbix attempts to check services on containers where those services do not exist or require unique input for monitoring. 
============
1. copy vzctl.sh to /etc/zabbix/
2. modify /etc/zabbix/zabbix_agentd.d/openvz.conf to create custom UserParameter definitions for monitor keys.
3. create monitors using the key like this: `openvz.ct.intcheck[{HOST.HOST},"/some/directory/some -command"]`

Container Monitor Option 2: Install extend check inside CT
============
Note: this approach requires the creation of a file within each container, which may not be possible in all cases (e.g. hosting company with thousands of containers and no back door SSH key to allow automated file creation via chef, puppet, ansible, etc). The advantage of this approach is that it allows for per-host customized scripting of monitors. For example this approach is ideal in a situation where you wish to have a single monitor for web server availability but your containers may use Apache, Nginx, different linux flavor, etc.
============
1. copy ctextcheckdiscover.pl ctextcheck.sh to /etc/zabbix/
2. create directory /etc/zabbix inside CT and copy ctextcheck/ct_check.sh there.
3. edit ct_check.sh to create custom UserParameter definitions for monitor keys. 
4. enable discovery rule "discover container external checks" in CT nodes.

Testing
===========
Identify problems using zabbix_get from your Zabbix server, like so, where 11111 = container CTID:

`# zabbix_get -s some.website.ext -k openvz.ct.intcheck[11111,"service sshd status"]`
`openssh-daemon (pid  875) is running...`

Known Issues
===========
If you have problem with import template "Template OpenVZ Node.xml", try using template without discovery rule and add it later manually.
https://github.com/Lelik13a/Zabbix-OpenVZ/issues/2
