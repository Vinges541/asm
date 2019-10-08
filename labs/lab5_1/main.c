#include <stdio.h>
extern CopyFile_(char* dstFileName, char* srcFileName);
int main(int argc, char* argv[], char* envp[])
{
	CopyFile_(argv[2], argv[1]);
	return;
}