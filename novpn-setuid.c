// The following code is heavly based on this GitHub Gist:
// https://gist.github.com/parke/6c2918a4dea329ae9e7ac238b6ee70bf

#define PATH_TO_NAMESPACE "/run/netns/novpn"

#define _GNU_SOURCE

#include <sched.h>
#include <pwd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <unistd.h>
#include <stdlib.h>

int die_f(int line_number) { 
	exit(line_number);
	return -1;
}

#define die (die_f(__LINE__))

int main(int argc, char* argv[])
{
	getuid() == 0 && die; // must not be real root
	getgid() == 0 && die; // must not be real root group
	geteuid() == 0 || die; // must be effective root

	int fd = open(PATH_TO_NAMESPACE, O_RDONLY);
	fd == -1 && die;
	setns(fd, CLONE_NEWNET) == 0 || die;
	close(fd) == 0 || die;

	// bind mount resolv.conf
	unshare(CLONE_NEWNS) == 0 || die;
	mount("/etc/netns/novpn/resolv.conf", "/etc/resolv.conf", "none", MS_BIND | MS_SLAVE, NULL);

	setuid(getuid()) == 0 || die; // drop effecitve root
	setgid(getgid()) == 0 || die; // drop effective root group

	if (argc > 1) {
		execvp(argv[1], argv + 1);
	} else {
		execl(getpwuid(getuid())->pw_shell, "", NULL);
	}

	return die;
}
