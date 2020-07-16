#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

enum error
{
    wrong_arg_1_or_2 = 1,
    zero_division,
    unknown_operation
};

const char* error_string_wrong_arg = "Wrong arg1 or arg2";
const char* error_string_zero_div = "Zero division";
const char* error_string_unknown_operation = "Unknown operation";

bool my_atoi(const char* str, int* num)
{

}

int main(int argc, char* argv[])
{
    int error_code = 0;
    int lhs, rhs;
    if(!(my_atoi(argv[1], &lhs) && my_atoi(argv[2], &rhs)))
    {
        printf("%s\n", error_string_wrong_arg);
        return wrong_arg_1_or_2;
    }
    int res;
    switch(argv[2][0])
    {
        case '+':
        {
            res = lhs+rhs;
            break;
        }
        case '-':
        {
            res = lhs-rhs;
            break;
        } 
        case 'X':
        {
            res = lhs*rhs;
            break;
        }
        case '/':
        {
            if(rhs == 0)
            {
                printf("%s\n", error_string_zero_div);
                return zero_division;
            }
            res = lhs/rhs;
            break;
        }
        default:
        {
            printf("%s\n", error_string_unknown_operation);
            return unknown_operation;
        }
    }
    printf("%d", res);
    return 0;
}