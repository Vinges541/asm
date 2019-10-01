#include <stdio.h>
#include <locale.h>
#include <string.h>
extern void Replace(char* str, char c1, char c2);
//c1 что заменять 
//c2 на что заменять
extern char* ReplaceStr(const char* text, const char* pattern, const char* rep);
//text где заменять
//pattern что заменять
//rep	на что заменять
#define BUFFER_SIZE 256
int main() {
	setlocale(LC_ALL, "ru-RU");
	printf("Replace:\n");
	printf("Введите строку: ");
	char str[BUFFER_SIZE];
	fgets(str, sizeof(str), stdin);
	//scanf_s("%s", str, sizeof(str));
	printf("Введите, что заменять и на что заменять: ");
	char c1, c2;
	scanf_s("%c %c", &c1, sizeof(c1), &c2, sizeof(c2));
	Replace(str, c1, c2);
	printf("%s\n", str);
	/*printf("Введите, где заменять, что и на что заменять:\n");
	char text[BUFFER_SIZE], pattern[BUFFER_SIZE], rep[BUFFER_SIZE];
	scanf_s("%s", text, sizeof(text));
	scanf_s("%s", pattern, sizeof(text));
	scanf_s("%s", rep, sizeof(text));*/
	return 0;
}