#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char* argv[]) {
	char command[512] = "/bin/ip netns e novpn /bin/su ";
	strcat(command, getlogin());

	if (argc > 1) {
		strcat(command, " -c ' ");

		for (int i = 1; i < argc; i++) {
			strcat(command, argv[i]);
			strcat(command, " ");
		}

		strcat(command, "'");
	}

	setuid(0);
	system(command);

	return 0;
}
