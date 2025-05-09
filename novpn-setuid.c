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
#include <string.h>

int die_f(int line_number) { 
	exit(line_number);
	return -1;
}

#define die (die_f(__LINE__))

char* strconcat(const char *s1, const char *s2)
{
	char *result = malloc(strlen(s1) + strlen(s2) + 1);
	if (result == 0) die;
	strcpy(result, s1);
	strcat(result, s2);

	return result;
}

int main(int argc, char* argv[])
{
	int fd = open(PATH_TO_NAMESPACE, O_RDONLY);
	fd == -1 && die;
	setns(fd, CLONE_NEWNET) == 0 || die;
	close(fd) == 0 || die;

	char* env_xdg_runtime_dir = getenv("XDG_RUNTIME_DIR");
	if (env_xdg_runtime_dir == 0) env_xdg_runtime_dir = "/tmp";
	char* flatpak_monitor_resolvconf = strconcat(env_xdg_runtime_dir, "/.flatpak-helper/monitor/resolv.conf");

	unshare(CLONE_NEWNS) == 0 || die;
	mount("none", "/", "none", MS_PRIVATE|MS_REC, NULL) == 0 || die;
	mount("/etc/netns/novpn/resolv.conf", "/etc/resolv.conf", "none", MS_BIND, NULL) == 0 || die;
	mount("/etc/resolv.conf", flatpak_monitor_resolvconf, "none", MS_BIND, NULL) == 0 || die;
	mount("/usr/libexec/novpn/resolvconf", "/bin/resolvconf", "none", MS_BIND, NULL) == 0 || die;
	mount("/etc/netns/novpn/.blank", "/run/systemd/resolve", "none", MS_BIND, NULL) == 0 || die;

	free(flatpak_monitor_resolvconf);

	if (argc > 1) {
		execvp(argv[1], argv + 1);
	} else {
		execl(getpwuid(getuid())->pw_shell, "", NULL);
	}

	return die;
}
