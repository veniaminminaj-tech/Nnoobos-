/*
 * KolibriX C starter example.
 *
 * This is a portable C entry-point example. Building it as a native
 * KolibriOS application requires the matching KolibriOS SDK/toolchain,
 * startup objects and linker configuration.
 */
int main(void)
{
    volatile unsigned int result = 20 + 22;
    (void)result;
    return 0;
}