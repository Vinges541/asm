#include <stdio.h>

int main(int argc, char *argv[], char *envp[]) {

	int i = 0;
	char **p = argv;

	for (i = 0; i < argc; ++i) {
		printf ("%s\n", argv[i]);
		}
	
	while (argv[i]) {
		printf ("%s\n", argv[i]);
		++i;
		}

	while (*p) {
		printf ("%s\n", *p);
		p++;
		}

	return 0;
}