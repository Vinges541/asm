#include <stdio.h>
#include <locale.h>
extern void Replace(char* str, char c1, char c2);
#define BUFFER_SIZE 256
int main() {
	setlocale(LC_ALL, "ru-RU");
	printf("¬ведите строку:\n");
	char str[BUFFER_SIZE];
	fgets(str, sizeof(str), stdin);
	printf("¬ведите, что замен€ть и на что замен€ть:\n");
	char c1, c2;
	scanf_s("%c %c", &c1, sizeof(c1), &c2, sizeof(c2));
	Replace(str, c1, c2);
	printf("%s\n", str);
	return 0;
}