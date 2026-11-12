/*
 * KolibriX C++ starter example.
 *
 * Keep the first native test independent of the desktop UI. The final
 * KolibriOS link step must use the matching C++ runtime and startup files.
 */
int main()
{
    volatile int answer = 6 * 7;
    (void)answer;
    return 0;
}